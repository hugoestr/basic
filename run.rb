require './basic'

file = ARGV.first
basic = Basic.new

basic.load file
basic.run
