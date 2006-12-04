#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for Schedule classes
# Author:: Matthew Lipper
class ScheduleTest < Test::Unit::TestCase

  include Runt

  def setup
    # Jane is very busy these days.
    @sched=Schedule.new
    # Elmo's World is on TV: Mon-Fri 8am-8:30am
    @elmo=Event.new("Elmo's World")
    @elmo_broadcast=(REWeek.new(Mon,Fri) & REDay.new(8,00,8,30))
    @sched.add(@elmo,@elmo_broadcast)
    #Oobi's on TV: Thu-Sat 8:30am-9am
    @oobi=Event.new("Oobi")
    @oobi_broadcast=(REWeek.new(Thu,Sat) & REDay.new(8,30,9,00))
    @sched.add(@oobi,@oobi_broadcast)
    @during_elmo=PDate.new(2004,5,4,8,06)
    @not_during_elmo=PDate.new(2004,5,1,8,06)
    @during_oobi=PDate.new(2004,4,30,8,56)
    @not_during_oobi=PDate.new(2004,5,1,8,12)  
  end

  def test_include
    # Check Elmo
    assert(@sched.include?(@elmo, @during_elmo))
    assert(!@sched.include?(@elmo,@not_during_elmo))
    assert(!@sched.include?(@elmo,@during_oobi))
    # Check Oobi
    assert(@sched.include?(@oobi, @during_oobi))
    assert(!@sched.include?(@oobi,@not_during_oobi))
    assert(!@sched.include?(@oobi,@not_during_elmo))
  end

  def test_select_all
    # select all
    all=@sched.select {|ev,xpr| true; }
    assert all.size==2
    assert all.include?(@elmo)
    assert all.include?(@oobi)
  end

  def test_select_none
      # select none
    assert((@sched.select {|ev,xpr| false; }).size==0)
  end

  def test_select_some
    # select oobi only 
    some=@sched.select {|ev,xpr| @oobi.eql?(ev); }
    assert some.size==1
    assert !some.include?(@elmo)
    assert some.include?(@oobi)
    some.clear
    # select elmo only 
    some=@sched.select {|ev,xpr| @elmo.eql?(ev); }
    assert some.size==1
    assert some.include?(@elmo)
    assert !some.include?(@oobi)
  end

  def test_events
    events=@sched.events(PDate.new(2006,12,4,11,15))
    assert_equal 0,events.size
    # The Barney power hour which overlaps with Elmo
    barney=Event.new("Barney")
    @sched.add(barney,REDay.new(7,30,8,30))
    events=@sched.events(PDate.new(2006,12,4,8,15))
    assert_equal 2,events.size
    assert events.include?(barney)
    assert events.include?(@elmo)
  end

  def test_update
    @sched.update(Event.new("aaa")){|ev|assert_nil(ev)}
    @sched.update(@elmo){|ev|assert_equal(@elmo_broadcast,ev)}
    @sched.update(@oobi){|ev|assert_equal(@oobi_broadcast,ev)}
  end

  def test_select_old
    @sched=Schedule.new
    e1=Event.new("e1")
    assert(!@sched.include?(e1,nil))
    range=RSpec.new(DateRange.new(PDate.new(2006,12,3),PDate.new(2007,1,24)))
    in_range=PDate.new(2007,1,4)
    assert(range.include?(in_range))
    out_of_range=PDate.new(2006,1,4)
    assert(!range.include?(out_of_range))
    @sched.add(e1,range)
    assert(@sched.include?(e1,in_range))
    assert(!@sched.include?(e1,out_of_range))
  end

  def test_dates
    # range: May 1st, 2004 to May 31st, 2004
    d_range = DateRange.new(PDate.day(2004,5,1), PDate.day(2004,5,31))
    @sched = Schedule.new
    event = Event.new("Visit Ernie")
    # First and last Friday of the month
    expr1 = DIMonth.new(1,Fri) |  DIMonth.new(-1,Fri)
    @sched.add(event,expr1)
    dates = @sched.dates(event,d_range)
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
    # Setup a @schedule w/first expression
    @sched = Schedule.new
    @sched.add(Event.new("Snafubar Opening"),expr1)
    resource = Resource.new(@sched)
    # Add a another overlapping event 
    resource.add_event(Event.new("Yodeling Lesson"),expr2)
    # Create a new resource using the same schedule
    resource2 = Resource.new(@sched)
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
