
Given /I have a hello world program/ do
  @path = 'basic/hello.bas'
  File.file? @path 
end

Given /I have a '(.+)' program/ do |name|
  @path = "basic/#{name.gsub ' ', '_'}.bas"
  File.file? @path 
end

When /I run the interpreter/ do
  @output = "output.txt"
  command = "ruby run.rb #{@path} > #{@output}"
  system command
end

Then /I should get as output '(.+)'/ do |content|
  output = File.read(@output)
  result = output.scan content
  result.count.should > 0
end
