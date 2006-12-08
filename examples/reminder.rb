#!/usr/bin/ruby

# NOTE this is slightly broken; it is in the process of being fixed
base = File.basename(Dir.pwd)
if base == "examples" || base =~ /runt/
  Dir.chdir("..") if base == "examples"
  $LOAD_PATH.unshift(Dir.pwd + '/lib')
  Dir.chdir("examples") if base =~ /runt/
end




require 'runt'

class Reminder
  include Runt

  def initialize(schedule)
    @schedule=schedule
  end

  def next_times(event,end_point,now=Time.now)
    @schedule.dates(event,DateRange.new(now,end_point))
  end
end 

# start of range whose occurrences we want to list
# TODO fix Runt so this can be done with Time instead 
#      e.g., now=Time.now
#now=Time.parse("13:00")
#now.date_precision=Runt::DPrecision::MIN
now=Runt::PDate.min(2006,12,8,13,00)

# end of range
soon=(now + 10.minutes)

# Sanity check
print "start: #{now.to_s} (#{now.date_precision}) end: #{soon.to_s} (#{soon.date_precision})\n"

#
# Schedule used to house TemporalExpression describing the recurrence from 
# which we'd list to generate a list of dates. In this example, some Event
# occuring every 5 minutes.
# 
schedule=Runt::Schedule.new

# Some event whose schedule we're interested in
event=Runt::Event.new("whatever")

# Add the event to the schedule (
# NOTE: any Object that is a sensible Hash key can be used
schedule.add(event,Runt::EveryTE.new(now,5.minutes))

# Example domain Object using Runt 
reminder=Reminder.new(schedule)

# Call our domain Object with the start and end times and the event
# in which we're interested
#puts "times (inclusive) = #{reminder.next_times(event,soon,now).join('\n')}"

puts "times (inclusive):"
reminder.next_times(event,soon,now).each{|t| puts t}
