class Print

  def initialize(vars, parser)
    @variables = vars
    @parser = parser
  end

  def print(expression = ['\n'])
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
    result
  end

 private
# print methods
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
        result = @parser.evaluate input  
        input = []
    else
      result = input.shift
    end
    [result, input]
  end
  
  def get_value(token)
    (token =~ /^[a-zA-Z]$/) ? @variables[token] : token
  end

  def to_string(value)
      value = value.to_i.to_s if value.is_a? Float
      value
  end

end
