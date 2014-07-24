require './functions'
require './parser'
require './print'

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
     printer = Print.new @variables, Parser.new
     result = printer.print expression
     
    puts result
     result
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
    before << Parser.new.evaluate(after)
  end

end

