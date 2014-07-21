Feature: run the BASIC interpreter

  In order to run my BASIC programs
  As the user of BASIC
  I want to run the intepreter

  Scenario: run hello world
    Given I have a hello world program
    When I run the interpreter
    Then I should get as output 'Hello, World!'

  Scenario: print a number
    Given I have a 'print number' program
    When I run the interpreter
    Then I should get as output '4'

  Scenario: print a variable
    Given I have a 'print var' program
    When I run the interpreter
    Then I should get as output '10'
  
  Scenario: print an addition
    Given I have a 'print addition' program
    When I run the interpreter
    Then I should get as output '4'

   Scenario: print new line 
    Given I have a 'print newline' program
    When I run the interpreter
    Then I should get as output '\nover here!'

   Scenario: print several numbers
    Given I have a 'print several' program
    When I run the interpreter
    Then I should get as output '1              2'
  
   Scenario: print numbers in the 5 regions numbers
    Given I have a 'print five' program
    When I run the interpreter
    Then I should get as output '1              2              3              4              5'


  Scenario: print should write a new line if they run out of space
    Given I have a 'print six' program
    When I run the interpreter
    Then I should get as output '1              2              3              4              5              \n6'

  Scenario: print test and a number within the first region and then in the second one
    Given I have a 'print text and number' program
    When I run the interpreter
    Then I should get as output 'Place: 1       Live long and prosper'

  Scenario: print a long sentence and break the linke at character 76
    Given I have a 'print long sentence' program
    When I run the interpreter
    Then I should get as output 'This is a very long kind of a sentence that should run over the required nu\nmber of sentences'

