require_relative 'session'
require_relative 'timetable'

require 'io/console'
require 'date'
require 'fileutils'
require 'icalendar'

FileUtils.mkdir_p "out"

puts "Student ID: " unless ARGV[0]
user = ARGV[0] || gets.chomp

puts "Password: "
pass = STDIN.noecho(&:gets).chomp

puts 
puts "Getting user..."
session = ElsieSession.new user, pass
puts "Done!"
puts

# FORMAT = "%d %b %Y"
puts "Getting timetable for #{session.user}..."
timetable = ElsieTimetable.new(session)
timetable.call
cal = timetable.to_calendar

puts "Saving Calendar..."
File.write("out/unitcalendar.ics", cal.to_ical)
puts "Calendar saved to out/unitcalendar.ics!"
