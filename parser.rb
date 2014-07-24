class Expression
  attr_accessor :left, :right, :op, :parent

   def to_r
    if !@op.nil?
      result = "(#{write_exp @left} #{@op} #{write_exp @right})" 
      result = result.gsub(/\^/, "**") 
    else
      result = "(#{write_exp @left})"
    end
  end

  def get_root
    current = self
    
    while not current.parent.nil?
      current = current.parent
    end

    current 
  end
   
  def write_exp(value)
    result = "error"

    result = value.to_s if value.is_a? Numeric 
    result = value.to_r if value.is_a? Expression 

    result
  end
 
  def valid?
    result = false
    
    if (!@left.nil? && !@right.nil? && !@op.nil?) or (!@left.nil? && @op.nil? && @right.nil?)
      result = true
    end

    result
  end
end

class Parser
  attr_reader :state, :expression

  def initialize()
    @state = :begin

    @precedent = {
      "+" => 0, 
      "-" => 0, 
      "*" => 1, 
      "/" => 1, 
      "^" => 2 
    }
  end

  def evaluate(tokens)
    parse tokens
    expr = expression.to_r
    (eval expr)
  end

  def parse(tokens)
    stack = []
    current = Expression.new 
    @state = :left
    
    while tokens.length > 0 && @state != :syntax_error
      token = tokens.shift 

      case @state
        when  :new_expression
          case get_type(token)
            when :right_parens
              previous, p_state = stack.pop

              if previous.left.nil?
                previous.left = current
                @state = :op  
              else
                previous.right = current
                if tokens.length == 0
                  @state = :valid 
                else
                  @state = :new_expression
                end 
              end

              current = previous
            when :op
              new = Expression.new
              
              if @precedent[token] > @precedent[current.op.to_s]
                  new.left = current.right
                  new.op = token.to_sym
                  new.parent = current

                  current.right = new
                  current = new
                else
                  new.left = current 
                  new.op = token.to_sym
                  current.parent = new
                  current = new
              end
              @state = :right
            else 
             @state = :syntax_error 
          end
        when :left 
          case get_type(token)
            when :left_parens
             stack << [current, @state] 
             current = Expression.new
             @state = :left
            when :number 
              current.left = token.to_f
              @state = :op
            else
             @state = :syntax_error 
         end
        when :op
          case get_type(token)
            when :op
              current.op = token.to_sym
              @state = :right
            else 
             @state = :syntax_error 
          end
        when :right
          case get_type(token)
            when :left_parens
             stack << [current, @state] 
             current = Expression.new
             @state = :left
            when :number
              current.right = token.to_f

              if tokens.length == 0
                @state = :valid 
              else
                @state = :new_expression
              end
            else 
             @state = :syntax_error 
          end
      end

    end 

    root = current.get_root
    if root.valid? && tokens.length == 0 && stack.length == 0 
      @state = :valid
      @expression = root
    end

    if stack.length > 0
      @state = :unbalanced_parens
    end 
  end

  private

    def get_type(token)
      type = :invalid
      type = :number if is_number(token)
      type = :op if token =~ /[+\-*+^=><\/]|[<>][=>]/
      type = :variable if token =~ /[A-Za-z]/
      type = :left_parens if token =~ /[(]/
      type = :right_parens if token =~ /[)]/

      type
    end

    def is_number(token)
      true if Float(token) rescue false
    end

end
