#!/usr/bin/ruby

require 'test/unit'
require 'runt'
require 'schedule_tutorial'

class ReminderTest < Test::Unit::TestCase

  include Runt

  def setup
    @schedule = Schedule.new
    @north_event = Event.new("north side of the street will be ticketed")
    north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    @schedule.add(@north_event, north_expr)
    @south_event = Event.new("south side of the street will be ticketed")
    south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    @schedule.add(@south_event, south_expr)
    @mail_server = MailServer.new
    @reminder = Reminder.new(@schedule, @mail_server)
    @saturday_at_10 = PDate.min(2007,11,24,10,0,0)
    @monday_at_10 = PDate.min(2007,11,26,10,0,0)
    @tuesday_at_noon = PDate.min(2007,11,27,12,0,0)
  end
  def test_initalize
    assert_same @schedule, @reminder.schedule, "Expected #{@schedule} instead was #{@reminder.schedule}"
    assert_same @mail_server, @reminder.mail_server, "Expected #{@mail_server} instead was #{@reminder.mail_server}"
  end
  def test_send
    params = [@north_event, @south_event]
    result = @reminder.send(params)
    assert_email result, Reminder::TEXT + params.join(', ')
  end
  def test_check
    assert_equal 1, @reminder.check(@monday_at_10).size, "Unexpected size #{@reminder.check(@monday_at_10).size} returned"
    assert_same @north_event, @reminder.check(@monday_at_10)[0], "Expected Event #{@north_event}. Got #{@reminder.check(@monday_at_10)[0]}."
    assert_equal 1, @reminder.check(@tuesday_at_noon).size, "Unexpected size #{@reminder.check(@tuesday_at_noon).size} returned"
    assert_same @south_event, @reminder.check(@tuesday_at_noon)[0], "Expected Event #{@south_event}. Got #{@reminder.check(@tuesday_at_noon)[0]}."
    assert @reminder.check(@saturday_at_10).empty?, "Expected empty Array. Got #{@reminder.check(@saturday_at_10)}"
  end
  def test_run
    result = @reminder.run(@monday_at_10)
    assert_email result, Reminder::TEXT + @north_event.to_s
  end
  def assert_email(result, text)
    assert_equal Reminder::TO, result.to, "Unexpected value for 'to' field of Email Struct: #{result.to}"
    assert_equal Reminder::FROM, result.from, "Unexpected value for 'from' field of Email Struct: #{result.from}"
    assert_equal Reminder::SUBJECT, result.subject, "Unexpected value for 'subject' field of Email Struct: #{result.subject}"
    assert_equal text, result.text, "Unexpected value for 'text' field of Email Struct: #{result.text}"
  end
end

