require './basic'


describe Basic do
  before :each do
    @b = Basic.new
  end
 
  describe "print" do 
    it "should return the next string" do
      expected = "value"
      result = @b.print ["value"]
      result.should == expected
    end

    it "should check for variables" do
      @b.let ["D", "=", "54"]
      result = @b.print ["D"]      
      result.should == "54"
    end

    it "should print numbers" do
      result = @b.print ["45"]      
      result.should == "45"
    end

    it "should print evaluations" do
      result = @b.print ["45", "+", "2"]      
      result.should == "47"
    end
    
  end

  it "rem should return nothing" do
    result = @b.rem "a comment here"
    result.should == nil
  end

  it "end should return :end" do
    result = @b.end 
    result.should == :end
  end
  
  it "stop should return :end" do
    result = @b.stop 
  end

  it "end should set the current statement pointer to zero" do
    @b.end
    @b.counter.should == 0
  end

  it "let should assing a variable" do
    @b.let ["D", "=", "54"]
    @b.variables["D"].should_not be nil
  end

  it "data should store values in the data value" do
    expected = [1,2,3,4]
    @b.data [1,2] 
    @b.data [3,4]
    @b.s_data.should == expected 
  end

  it "read should assign as many values as variables it has from data" do 
    @b.data [1,2] 
    @b.read ["A", "B"]

    @b.variables["A"].should == 1
    @b.variables["B"].should == 2
  end

  it "goto should change the counter value " do
    @b.goto 20
    @b.counter.should == 20
  end

  it "if then will hange the counter if true" do
    expression = [["3", "=", "3"], "then", 40]
    @b.ifthen expression 
    @b.counter.should == 40
  end

  it "dim should create a variable that is an array" do
    @b.dim ["A", "13"]
    @b.variables["A"].should be_a Array
  end

  describe "for next" do
    before :each do
      @result = @b.for ["A", "=", "0", "TO", "5"]
    end

    it "should assign the variable" do
     @b.variables["A"].should == 0
    end

    it "should assign step" do
     @b.step.should == 1
    end
 
    it "should assign step when step exists" do
      @result = @b.for ["A", "=", "0", "TO", "5", "STEP", "-1"]
     @b.step.should == -1
    end

    it "should put the next line in the stack" do
      @b.line "10 PRINT \"Hello\""
      @b.for ["A", "=", "0", "TO", "5", "STEP", "-1"]
      line, conditional = @b.stack.pop  
      line.should == 10
    end

    it "should create a conditional " do
      @b.line "10 PRINT \"Hello\""
      @b.for ["A", "=", "0", "TO", "5", "STEP", "-1"]
      line, conditional = @b.stack.pop
      conditional.should == "@variables['A'] == 5" 
    end

    describe "next" do
      before :each do
        @b.stack.pop if @b.stack.length > 0

        @b.line "10 PRINT \"Hello\""
        @b.line "20 NEXT A"
        @b.line "30 END"
  
        @b.for ["A", "=", "0", "TO", "5"]
      
       2.times { @b.next_step }
      end
      
      it "should increase variable by step" do
        @b.next ["A"]
        @b.variables["A"].should == 1
      end

      it "should go back to stack line if conditional false" do
        @b.next ["A"]
        @b.counter.should == 10
      end

      it "should go forward to stack line if conditional false" do
       5.times do   
          @b.next ["A"]
         2.times { @b.next_step }
       end

        @b.counter.should == 30
      end

      it "when moving forward, clean the stack" do
       5.times do   
          @b.next ["A"]
         2.times { @b.next_step }
       end
        @b.stack.length.should == 0     
      end

    end
  end

   
  it "gosub should transfer the counter" do
    @b.gosub ["220"]
    @b.counter.should == 220
  end 

  it "gosub should put in the return stack the current line number" do
    @b.gosub ["220"]
    @b.stack.last.should == 0
  end

  it "return takes an item off the stack " do
    @b.gosub ["220"]
    @b.return
    @b.stack.length.should == 0
  end
 
  it "return should take back the counter +1" do
    @b.gosub ["220"]
    @b.return
    @b.counter.should == 1
  end
  it "+ should add numbers" do
    expression = [3, "+", 2]
    result = @b.evaluate expression
    result.should == 5
  end

  it "- should subtract numbers" do
    expression = [3, "-", 2]
    result = @b.evaluate expression
    result.should == 1
  end

  it "* should multiply numbers" do
    expression = [3, "*", 2]
    result = @b.evaluate expression
    result.should == 6 
  end
  
  it "/ should divide numbers" do
    expression = [6, "/", 2]
    result = @b.evaluate expression
    result.should == 3 
  end

  it "^ should raise to the power numbers" do
    expression = [6, "^", 2]
    result = @b.evaluate expression
    result.should == 36 
  end

  it "= should return  true when equal" do
    expression = [2, "=", 2]
    result = @b.evaluate expression
    result.should == true 
  end

  it "= should return false when not equal" do
    expression = [2, "=", 3]
    result = @b.evaluate expression
    result.should == false 
  end

  it "<> should return true when not equal" do
    expression = [2, "<>", 3]
    result = @b.evaluate expression
    result.should == true 
  end

  it "> should return true when a is greater than b" do
    expression = [5, ">", 3]
    result = @b.evaluate expression
    result.should == true 
  end
 
  it "< should return true when a is lesser than b" do
    expression = [3, "<", 5]
    result = @b.evaluate expression
    result.should == true 
  end
  
  it "<= should return true when a is lesser than b" do
    expression = [5, "<=", 5]
    result = @b.evaluate expression
    result.should == true 
  end

  it ">= should return true when a is lesser than b" do
    expression = [5, ">=", 5]
    result = @b.evaluate expression
    result.should == true 
  end
 
  it ">= should return true when a is lesser than b" do
    expression = [5, ">=", 5]
    result = @b.evaluate expression
    result.should == true 
  end

  it "should handle expressions with parentheses" do
    expression = ["3", "*", [ 5, "+", 5]]
    result = @b.evaluate expression
    result.should == 30 
  end

  it "should respect multiplications first" do
    expression = ["4", "+", ["3", "*", [5, "^", "2"]]]
    result = @b.evaluate expression
    result.should == 79 
  end

  it "def should define a one line function " do
    @b.def_fun ["FNZ(A)", "=", ["3", "+", "A"]] 
    @b.let ["X", "=", "2"]
    result = @b.evaluate "FNZ(X)"
    result.should == 5 
  end

 
  it "should load a line" do
    @b.line '10 PRINT "Hello World"'
    @b.program.length.should == 1
  end

  it "read_line should parse a PRINT statement" do
    result =  @b.read_line '10 PRINT "Hello World"'
    result.should == [10, "PRINT", ["Hello World"]] 
  end

  it "read_line should parse a let statement" do
    result =  @b.read_line '10 LET A = 23'
    result.should == [10, "LET", ["A", "=", 23.0]] 
  end

  it "read_line should handle end" do
    result = @b.read_line '10 END'
    result.should == [10, "END", []]
  end

  it "read_line should parse" do
    result = @b.read_line "10 LET A = 4 + 3 * 5 ^ 2"
    result.should ==  [10, "LET",["A", "=", 79.0]]
  end

  describe "running the interpreter" do
  end  
end
