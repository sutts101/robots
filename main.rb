require './robots.rb'

if ARGV.empty?
  puts "Usage: ruby main.rb <path_to_command_file>"
else
  command_string = File.read ARGV.first
  Command.parse_and_apply command_string
end
