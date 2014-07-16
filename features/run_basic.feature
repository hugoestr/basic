Feature: run the BASIC interpreter

  In order to run my BASIC programs
  As the user of BASIC
  I want to run the intepreter

  Scenario: run hello world
    Given I have a hello world program
    When I run the interpreter
    Then I should get as output "Hello, World!"
