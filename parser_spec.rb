require './parser'

describe Parser do

  before :each do 
    @p = Parser.new
  end

  it "should be created with state 'begin'" do
    @p.state.should == :begin
  end

  it "should find a single number to be an expression" do
    tokens = ["2"]
    @p.parse tokens
    @p.state.should == :valid
  end
 
  it "should print (2) expression when a single number" do
    tokens = ["2"]
    @p.parse tokens
    result = @p.expression.to_r
    result.should == '(2.0)'
  end

  it "should find 2 + 3 as a valid expression" do
    tokens = ["2", "+", "3"]
    @p.parse tokens
    @p.state.should == :valid
  end
  
  it "should find  + 2 3 as a syntax error" do
    tokens = [ "+", "2", "3"]
    @p.parse tokens
    @p.state.should == :syntax_error
  end

  it "should find 2 + 3 + 6 as a valid expression" do
    tokens = ["2", "+", "3", "+", "6"]
    @p.parse tokens
    @p.state.should == :valid
  end
  
  it "should find 2 + 3 + * as a syntax error" do
    tokens = ["2", "+", "3", "+", "+"]
    @p.parse tokens
    @p.state.should == :syntax_error
  end
 
  it "should find 2 + 3 + ( 5 + 7 ) as valid" do
    tokens = ["2", "+", "3", "+", "(", "5", "+", "7", ")"]
    @p.parse tokens
    @p.state.should == :valid
  end
  
  it "should find 2 + 3 + ( 5 + 7 ) as unbalanced_parens" do
    tokens = ["2", "+", "3", "+", "(", "5", "+", "7"]
    @p.parse tokens
    @p.state.should == :unbalanced_parens
  end
 
  it "should find 2 + (3 +  5 )+ 7  as valid" do
    tokens = ["2", "+",  "(", "3", "+", "5", ")", "+", "7"]
    @p.parse tokens
    @p.state.should == :valid
  end
 
  it "should write the expression" do
    tokens = ["2", "+",  "(", "3", "+", "5", ")", "+", "7"]
    @p.parse tokens
    result = @p.expression.to_r
    result.should == "((2.0 + (3.0 + 5.0)) + 7.0)"
  end


  it "should make exponents the highest level" do
    tokens = ["2", "+", "3", "+", "5", "^", "2"]
    @p.parse tokens
    result = @p.expression.to_r
    result.should == "((2.0 + 3.0) + (5.0 ** 2.0))"
  end
  
  it "should make exponents the highest level along with multiplication" do
    tokens = ["2", "*", "3", "*", "5", "^", "2"]
    @p.parse tokens
    result = @p.expression.to_r
    result.should == "((2.0 * 3.0) * (5.0 ** 2.0))"
  end
end
