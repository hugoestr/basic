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

