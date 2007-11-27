#!/usr/bin/ruby

require 'runt'

class Reminder
  
  TO = "me@myselfandi.com"
  FROM = "reminder@daemon.net"
  SUBJECT = "Move your car!"

  attr_reader :schedule, :mail_server

  def initialize(schedule,mail_server)
    @schedule = schedule
    @mail_server = mail_server
  end
  def run(date)
    result = self.check(date)
    self.send(result) if !result.empty?
  end
  def check(date)
    puts "Checking the schedule..." if $DEBUG
    return @schedule.events(date)
  end
  def send(events)
    text = "Warning: " + events.join(', ')
    return @mail_server.send(TO, FROM, SUBJECT, text)
  end
end

class MailServer
  Struct.new("Email",:to,:from,:subject,:text)
  def send(to, from, subject, text)
    puts "Sending message TO: #{to} FROM: #{from} RE: #{subject}..." if $DEBUG
    Struct::Email.new(to, from, subject, text)
   # etc... 
  end
end


if __FILE__ == $0

  include Runt

  schedule = Schedule.new
  north_event = Event.new("north side")
  north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
  schedule.add(north_event, north_expr)
  south_event = Event.new("south side")
  south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)      
  schedule.add(south_event, south_expr)
  reminder = Reminder.new(schedule, MailServer.new)
  while true
    sleep 15.minutes
    reminder.run Time.now
  end

end
