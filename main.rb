require_relative 'session'
require_relative 'user'
require_relative 'timetable'

require 'io/console'
require 'date'
require 'fileutils'
require 'icalendar'

# Edit these if you want to change the import range
STUDY_START = DateTime.new(2018, 7, 30)
STUDY_END   = DateTime.new(2018, 12, 30)

FileUtils.mkdir_p "out"

puts "Student ID: " unless ARGV[0]
user = ARGV[0] || gets.chomp

puts "Password: "
pass = STDIN.noecho(&:gets).chomp

puts 
session = ElsieSession.new user, pass
puts "Getting user..."
user = ElsieUser.new(session)
puts "Found User: #{user.id}"
puts

FORMAT = "%d %b %Y"
puts "Getting timetable for #{STUDY_START.to_date.strftime(FORMAT)} -> #{STUDY_END.to_date.strftime(FORMAT)}..."
timetable = ElsieTimetable.new(session, STUDY_START, STUDY_END)
cal = timetable.to_calendar

puts "Saving Calendar..."
File.write("out/unitcalendar.ics", cal.to_ical)
puts "Calendar saved to out/unitcalendar.ics!"