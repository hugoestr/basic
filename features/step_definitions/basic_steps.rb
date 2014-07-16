
Given /I have a hello world program/ do
  @path = 'basic/hello.bas'
  File.file? @path 
end

When /I run the interpreter/ do
  @output = "output.txt"
  command = "ruby run.rb #{@path} > #{@output}"
  system command
end

Then /I should get as output "Hello, World!"/ do
  output = File.read(@output)
  result = output.scan /Hello, World!/
  result.count.should > 0
end
