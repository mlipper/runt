#!/usr/bin/env ruby

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

  def test_using_a_schedule
        
    # September 18th - 19th, 2005, 8am - 10am 
    expr1=RSpec.new(DateRange.new(PDate.day(2005,9,18),PDate.day(2005,9,19))) & REDay.new(8,0,10,0)
    assert(expr1.include?(PDate.min(2005,9,18,8,15)))
    # September 19th - 20th, 2005, 9am - 11am 
    expr2=RSpec.new(DateRange.new(PDate.day(2005,9,19),PDate.day(2005,9,20))) & REDay.new(9,0,11,0) 
    # Quick sanuty check
    assert(expr1.overlap?(expr2))
    # Setup a schedule w/first expression
    sched = Schedule.new
    sched.add(Event.new("Snafubar Opening"),expr1)
    resource = Resource.new(sched)
    # Add a another overlapping event 
    resource.add_event(Event.new("Yodeling Lesson"),expr2)
    # Create a new resource using the same schedule
    resource2 = Resource.new(sched)
    # Add a another overlapping event and pass a block which should complain
    #resource.add_event(Event.new("Yodeling Lesson"),expr2) \
    #{|e,s| raise "Resource not available at requested time(s)." \
    #  if (@schedule.overlap?(s))} 
  end
end

class Resource
  def initialize(schedule)
    @schedule=schedule
  end
  def add_event(event,expr)
    if(block_given?) 
      yield(event,expr) 
    else
      @schedule.add(event,expr) 
    end
  end
end
