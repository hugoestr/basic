require './functions'
require './parser'

class Basic
  attr_reader :counter, :variables, :s_data, :step, :stack, :program, :functions

  def initialize()
    @variables = {}
    @s_data = []
    @counter = 0
    @stack = []
    @program = {} 
    @functions = Object.new
    @commands = {
      "PRINT" => :print,
      "LET"  => :let,
      "END" => :end
    }
    @source = []
  end

  def load(file)
    @source = File.open(file).readlines
   
    if @source.count > 0
      @source.each do |input|
        line input 
      end  
    end

  end 

  def run
    @counter = 0
    
    @program.keys.sort.each do |line_number|
     command, argument = @program[line_number]
     send @commands[command], argument
    end

  end

  def line(input)
    args =  read_line input
    line =  args.shift
    @program[line.to_f] = args
  end

  def print( expression = ['\n'])
    result = ''
    regions = 1

    expression.slice_before(',').each do |input|
      input, regions, result = check_regions input, regions, result
 
      begin
        token, input = value_of_expression input
        puts input.inspect
        value = get_value token 
        value = to_string value
        
        result += value
      end while input.count >= 1
     end
   
    result = guard_width(result)

    puts result
    result
  end

  def guard_width(text)
    (text.length > 75) ? text.scan(/.{1,75}/).join("\n") : text
  end

  def check_regions(input, regions, result)
      if input.first == ','
        
        result += (' ' * (15 - (result.length % 15)) )
        result += "\n" if regions % 5 == 0

        regions += 1

        input.shift
      end

      [input, regions, result] 
  end

  def value_of_expression(input)
    if input.count > 1 && input.first !~ /[A-Z ]+/ 
        result = parse_math input  
        input = []
    else
      result = input.shift
    end
    [result, input]
  end
  
  def get_value(token)
    (token =~ /^[a-zA-Z]$/) ? get_var(token) : token
  end

  def to_string(value)
      value = value.to_i.to_s if value.is_a? Float
      value
  end

  def rem(input)
  end
  
  def end(arg = nil) 
    stop
  end
  
 def stop()
    @counter = 0
    :end
 end

 def let(args)
   name, _, value = args
   @variables[name] = value.to_f
 end

 def dim(args)
   name, _, value = args
   @variables[name] = [] 
 end

 def read(args)
  args.each do |variable|
    let [variable, "", @s_data.shift]
  end
 end

 def data(args)
  args.each do |value| 
    @s_data << value
  end
 end

 def goto(arg)
  @counter = arg
 end

 def ifthen(args)
   conditional, _, line_number = args
   @counter = line_number if evaluate(conditional)
 end

 def for(args)
  variable, op , value, _ , limit, _, step = args
  let [variable, op, value]
  @step = (!step.nil?) ? step.to_f : 1

  line = next_line if @program.length > 0
  conditional  = "@variables['#{variable}'] == #{limit}"

  @stack << [line, conditional]
 end

 def next(args)
  variable = args.first
  @variables[variable] = @variables[variable] +  @step

  line, conditional = @stack.last
  
  if eval(conditional) 
    clean_for
    counter = next_line
  else
    goto line 
  end
 end

 def gosub(args)
  @stack << @counter
  goto args.first.to_i
 end

 def return
  line = @stack.pop
  goto (line + 1)
 end


 def evaluate(args)
   result = nil
   a, operator, b = args
   
   if a =~ /FN.\(.\)/
    return eval_func args
   end

   a =  (a.is_a? Array) ? evaluate(a) : a.to_f
   b =  (b.is_a? Array) ?  evaluate(b) : b.to_f

  result = 
   case operator
   when "+"
      a + b
   when "-"
     a - b
   when "*"
     a * b
   when "/"
     a / b
   when "^"
     a ** b
   when "="
     a == b
   when "<>"
     a != b
   when ">"
     a > b
   when "<"
     a < b
   when "<="
     a <= b
   when ">="
     a >= b
   end
 end

 def eval_func(args)
  variable = args.match /\((.)\)/
  text = args.gsub /\(.\)/, "(#{@variables[variable[1]]})"
  execute = "@functions.#{text}"
  eval(execute) 
 end

 def def_fun(args)
  name, _ , expression = args 
  
  variable = name.match /\((.)\)/
  replaced = name.gsub /\(.\)/, "(#{variable[1].downcase})"
  
  expression_text = expression.join " " 
  exp_replaced = expression_text.gsub " #{variable[1]}", " #{variable[1].downcase}" 
  add = "def @functions.#{replaced}; #{exp_replaced}; end"
  eval(add)
 end

 def next_step
  @counter = next_line 
 end

  def read_line(args)
    line = args.match /^(?<number>\d+) (?<statement>\w+)\s*(?<expression>.*)$/
    expression = []
    
    if not line[:expression].nil?

      exp_text = line[:expression]

      type = exp_text.match /(?<string>["'].*["'])|(?<expression>.*)/

      if not type[:string].nil?
        if type[:string] =~ /,/
          puts "in here #{type[:string]}"
          expression = type[:string].scan(/"[^"]+"|-?\d*\.?\d+?|,/).
            map {|s| s.gsub /"/, ''} 
        else 
          expression = [type[:string].gsub('"', '')]
        end
      else
        items = type[:expression].split ' ' #/"[^"]+?"|-?\d+\.?\d+?|[,+<>*=-^]|\w/ 
        expression = parse_expression items
      end
    end 

    result = [line[:number].to_i, line[:statement], expression]  
  end

 private

  def clean_for
    @stack.pop
  end

  def next_line
    result = 0
    lines = program.keys.sort
    
    lines.each do |line|
      result = line
      break if @counter < line
    end

    result
  end

  def get_var(name)
    @variables[name]
  end

  def parse_expression(items)
    return [] if items.nil? || items.length == 0

    before = []
    after = []
    flag = false
   
    # break it up 
    items.each do |item|
      if !flag
        before << item
        flag = true if item == '='
      else
        after << item
      end 
    end

    return items if not flag # back if not assignment in the statement

    # Parse the mathematical stuff
    before << parse_math(after)
  end

  def parse_math(tokens)
    p = Parser.new 
    p.parse tokens
    expr = p.expression.to_r
    (eval expr)
  end
end

