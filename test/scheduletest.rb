#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for Schedule classes
# Author:: Matthew Lipper
class ScheduleTest < Test::Unit::TestCase

  include Runt

  def test_add

    #Jane is very busy these days.
    j_sched = Schedule.new

    #Elmo's World is on TV: Mon-Fri 8am-8:30am
    elmo = Event.new("Elmo's World")
  
    j_sched.add(elmo,(REWeek.new(Mon,Fri) & REDay.new(8,00,8,30)))
    assert(j_sched.include?(elmo, PDate.new(2004,5,4,8,06)))
    assert(!j_sched.include?(elmo, PDate.new(2004,5,1,8,06)))
    assert(!j_sched.include?(elmo, PDate.new(2004,5,3,9,06)))

    #Oobi's on TV: Thu-Sat 8:30am-9am
    oobi = Event.new("Oobi")

    j_sched.add(oobi,(REWeek.new(Thu,Sat) & REDay.new(8,30,9,00)))

    assert(j_sched.include?(oobi, PDate.new(2004,4,30,8,56)))
    assert(!j_sched.include?(oobi, PDate.new(2004,5,1,8,12)))
    assert(!j_sched.include?(oobi, PDate.new(2004,5,5,8,50)))

  end

  def test_dates

    # range: May 1st, 2004 to May 31st, 2004
    d_range = DateRange.new(PDate.day(2004,5,1), PDate.day(2004,5,31))
    sched = Schedule.new
    event = Event.new("Visit Ernie")

    # First and last Friday of the month
    expr1 = DIMonth.new(1,Fri) |  DIMonth.new(-1,Fri)
    sched.add(event,expr1)

    dates = sched.dates(event,d_range)
    expected = [PDate.day(2004,5,7), PDate.day(2004,5,28)]
    assert_equal(expected,dates)
  end

end

