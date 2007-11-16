#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'time'

$DEBUG=false

# Unit tests for TExpr classes
# Author:: Matthew Lipper

class TExprTest < Test::Unit::TestCase

  include Runt
  include DPrecision

  def test_collection_te
    #base class that should always return false
    expr = Collection.new
    assert(!expr.include?(Date.today))
  end
  

  def test_collection_te_to_s
    assert_equal 'empty', Collection.new.to_s
    assert_equal 'empty', Collection.new.to_s{['b','oo']}
    expr = Collection.new
    dim = DIMonth.new(First,Tuesday)
    expr.expressions << dim
    assert_equal 'ff' + dim.to_s, expr.to_s{['ff','nn']}
    red = REDay.new(0,0,6,30)
    expr.expressions << red
    assert_equal 'ff' + dim.to_s + 'nn' + red.to_s, expr.to_s{['ff','nn']}
    wim = WIMonth.new(Second_to_last)
    expr.expressions << wim
    assert_equal 'ff' + dim.to_s + 'nn' + red.to_s + 'nn' + wim.to_s, expr.to_s{['ff','nn']}
  end

  def test_union_te_to_s
    dim = DIMonth.new(First,Tuesday) 
    red = REDay.new(0,0,6,30)
    expr = dim | red
    assert_equal 'every ' + dim.to_s + ' or ' + red.to_s, expr.to_s
  end
  
  def test_union_te
    #midnight to 6:30am AND/OR first Tuesday of the month
    expr = REDay.new(0,0,6,30) | DIMonth.new(First,Tuesday)
    assert(expr.include?(PDate.day(2004,1,6))) #January 6th, 2004 (First Tuesday)
    assert(expr.include?(PDate.hour(1966,2,8,4))) #4am (February, 8th, 1966 - ignored)
    assert(!expr.include?(PDate.min(2030,7,4,6,31))) #6:31am, July, 4th, 2030
  end
  
  def test_spec_te_include
    expr1 = Spec.new(PDate.day(2003,12,30))
    expr2 = Spec.new(PDate.day(2004,1,1))
    assert expr1.include?(Date.new(2003,12,30))
    assert !expr1.include?(Date.new(2003,12,31))
    assert expr2.include?(Date.new(2004,1,1))
    assert !expr2.include?(Date.new(2003,1,1))
    expr3 = Spec.new(DateTime.civil(2006,3,11,8,30))
    assert expr3.include?(DateTime.civil(2006,3,11,8,30))
  end

  def test_spec_te_to_s
    pdate = PDate.day(2003,12,30)
    expr1 = Spec.new(pdate)
    assert_equal expr1.to_s, pdate.to_s
  end

  def test_rspec_te
    #NOTE:
    #Using standard range functionality like the following:
    #...  expr1 = RSpec.new(r_start..r_end)
    #...  assert(expr1.include?((r_start+10)..(r_end-10)))
    #will work. However, it takes a LONG time to evaluate if range is large
    #and/or precision is small. Use DateRange instead

    r_start = PDate.sec(2004,2,29,16,24,12)
    r_end = PDate.sec(2004,3,2,4,22,58)
    #inclusive range equivalent to r_start..r_end
    expr1 = RSpec.new(DateRange.new(r_start,r_end))
    assert(expr1.include?(PDate.sec(2004,2,29,16,24,12)))
    assert(expr1.include?(PDate.sec(2004,3,2,4,22,58)))
    assert(expr1.include?(DateTime.new(2004,3,1,23,00)))
    assert(!expr1.include?(DateTime.new(2004,3,2,4,22,59)))
    assert(!expr1.include?(Date.new(2003,3,1)))
    #exclusive range equivalent to r_start...r_end
    expr2 = RSpec.new(DateRange.new(r_start,r_end,true))
    assert(expr2.include?(PDate.sec(2004,2,29,16,24,12)))
    assert(!expr2.include?(PDate.sec(2004,3,2,4,22,58)))
    r_sub = DateRange.new( (r_start+10), (r_end-10) )
    assert(expr1.include?(r_sub))
  end
  
  def test_rspec_te_to_s
    range = DateRange.new(PDate.new(2006,2,25),PDate.new(2006,4,8))
    expr = RSpec.new(range)
    assert_equal expr.to_s, range.to_s 
  end
  
  def test_intersection_te
    #Should match the first Sunday of March and April
    expr1  = REYear.new(3,4) & DIMonth.new(First,Sunday)
    assert(expr1.include?(PDate.new(2004,3,7))) #Sunday, March 7th, 2004
    assert(!expr1.include?(PDate.new(2004,4,1))) #First Sunday in February, 2004
    expr2 = REWeek.new(Mon,Fri) & REDay.new(8,00,8,30)
    assert(expr2.include?( PDate.new(2004,5,4,8,06)))
    assert(!expr2.include?(PDate.new(2004,5,1,8,06)))
    assert(!expr2.include?(PDate.new(2004,5,3,9,06)))
  end
  
  def test_intersection_te_to_s
    dim = DIMonth.new(First,Tuesday) 
    red = REDay.new(0,0,6,30)
    expr = dim & red
    assert_equal 'every ' + dim.to_s + ' and ' + red.to_s, expr.to_s
  end

  def test_difference_te
    #Should match for 8:30 pm to 11:04 pm
    diff_expr  = REDay.new(20,30,00,00) - REDay.new(23,04,6,20)
    #8:45 pm (May 1st, 2003 - ignored)
    assert(diff_expr.include?(PDate.new(2003,5,1,20,45)))
    #11:05 pm (February 1st, 2004 - ignored)
    assert(!diff_expr.include?(PDate.new(2004,2,1,23,05)))
    #8:00 pm (May 1st, 2003 - ignored)
    assert(!diff_expr.include?(PDate.new(2003,5,1,20,00)))
  end

  def test_diff_to_s
    rey1 = REYear.new 3,1,6,2
    rey2 = REYear.new 4,15,5,20
    expr = rey1 - rey2
    assert_equal rey1.to_s + ' except for ' + rey2.to_s, expr.to_s
  end
    

  def test_memorial_day
    # Monday through Friday, from 9am to 5pm
    job = REWeek.new(Mon,Fri) & REDay.new(9,00,17,00)
    # Memorial Day (U.S.)
    memorial_day = REYear.new(5) & DIMonth.new(Last,Monday)
    # May 29th, 2006
    last_monday_in_may = PDate.min(2006,5,29,10,12)
    # Before 
    assert job.include?(last_monday_in_may)
    assert job.include?(PDate.min(20006,5,30,14,00))
    # Add Diff expression
    job_with_holiday = job - last_monday_in_may
    assert !job_with_holiday.include?(last_monday_in_may)
    # Still have to work on Tuesday
    assert job.include?(PDate.min(20006,5,30,14,00))
  end
  
  def test_combined_te
    #This is a hack.....
    #In the U.S., Memorial Day begins the last Monday of May
    #
    #The month of May
    may=REYear.new(5)
    #Monday through Saturday
    monday_to_saturday = REWeek.new(1,6)
    #Last week of (any) month
    last_week_in = WIMonth.new(Last_of)
    #So, to say 'starting from the last Monday in May',
    #we need to select just that last week of May begining with
    #the Monday of that week
    last_week_of_may = may & monday_to_saturday & last_week_in

    #This is another hack similar to the above, except instead of selecting a range
    #starting at the begining of the month, we need to select only the time period in
    #September up until Labor Day.
    #
    #In the U.S., Labor Day is the first Monday in September
    #
    #The month of September
    september=REYear.new(9)
    #First week of (any) month
    first_week_in = WIMonth.new(First)
    entire_first_week_of_september = september & first_week_in
    #To exclude everything in the first week which occurs on or after Monday.
    first_week_of_september=entire_first_week_of_september - monday_to_saturday
    #June through August
    june_through_august=REYear.new(6,First,8)
    assert(june_through_august.include?(PDate.day(2004,7,4)))
    #Finally!
    summer_time = last_week_of_may | first_week_of_september | june_through_august

    #Will work, but will be incredibly slow:
    #  assert(summer_time.include?(PDate.min(2004,5,31,0,0)))
    assert(summer_time.include?(PDate.day(2004,5,31,0,0)))
    assert(summer_time.include?(PDate.day(2004,7,4)))
    #also works...also slow:
    #  assert(!summer_time.include?(PDate.min(2004,9,6,0,0)))
    assert(!summer_time.include?(PDate.hour(2004,9,6,0,0)))

  end
  def test_nyc_parking_te

    #Monday, Wednesday, Friday
    mon_wed_fri = DIWeek.new(Mon) | \
                    DIWeek.new(Wed) | \
                      DIWeek.new(Fri)


    #Wednesday (at 7:15pm - ignored)
    assert(mon_wed_fri.include?(DateTime.new(2004,3,10,19,15)))

    #Sunday (at 9:00am - ignored)
    assert(!mon_wed_fri.include?(DateTime.new(2004,3,14,9,00)))

    #8am to 11am
    eight_to_eleven = REDay.new(8,00,11,00)

    #=> Mon,Wed,Fri - 8am to 11am
    expr1 = mon_wed_fri & eight_to_eleven

    #Tuesdays, Thursdays
    tues_thurs = DIWeek.new(Tue) | DIWeek.new(Thu)

    #11:30am to 2pm
    eleven_thirty_to_two = REDay.new(11,30,14,00)

    #Noon (on Monday - ignored)
    assert(eleven_thirty_to_two.include?(DateTime.new(2004,3,8,12,00)))

    #Midnite (on Thursday - ignored)
    assert(!eleven_thirty_to_two.include?(DateTime.new(2004,3,11,00,00)))


    #=> Tues,Thurs - 11:30am to 2pm
    expr2 = tues_thurs & eleven_thirty_to_two

    #
    #Sigh...now if I can only get my dad to remember this...
    #
    parking_ticket = expr1 | expr2

    assert(parking_ticket.include?(DateTime.new(2004,3,11,12,15)))
    assert(parking_ticket.include?(DateTime.new(2004,3,10,9,15)))
    assert(parking_ticket.include?(DateTime.new(2004,3,10,8,00)))

    assert(!parking_ticket.include?(DateTime.new(2004,3,11,1,15)))

    # Simplified
    e1 = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    e2 = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    ticket = expr1 | expr2
    assert(ticket.include?(DateTime.new(2004,3,11,12,15)))
    assert(ticket.include?(DateTime.new(2004,3,10,9,15)))
    assert(ticket.include?(DateTime.new(2004,3,10,8,00)))
    assert(!ticket.include?(DateTime.new(2004,3,11,1,15)))
 end

  def test_union_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 12, 31)
    month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] 
    expr = DIMonth.new(Last, Friday) | DIMonth.new(1, Tuesday)
    dates = expr.dates(date_range)
    assert dates.size == 24
    dates.each do |d|
      unless (d.wday == 2 and d.day < 8) or \
	(d.wday == 5 and d.day > month_days[d.month-1] - 8)
        assert false, d.to_s 
      end
    end
  end

  def test_intersection_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 12, 31)
    expr = DIWeek.new(Sunday) & DIMonth.new(Second, Sunday)
    dates = expr.dates(date_range)
    assert( dates.size == 12 )
    other_dates = DIMonth.new(Second, Sunday).dates(date_range)
    dates.each { |d| assert( other_dates.include?(d) ) }
  end

  def test_diff_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 1, 31)
    expr = REYear.new(1, 1, 1, 31) - REMonth.new(7, 15)
    dates = expr.dates(date_range)
    assert dates.size == 22, dates.size
  end

  def test_use_time_class
    monday=DIWeek.new(Mon) & REDay.new(9,30,17,30)
    tues_to_fri=REWeek.new(Tue, Fri) & REDay.new(9,00,17,30)
    exp=monday | tues_to_fri
    assert(!exp.include?(Time.parse('Monday 06 November 2006 07:38')))
    assert(exp.include?(Time.parse('Monday 06 November 2006 13:37')))
    assert(exp.include?(Time.parse('Friday 10 November 2006 16:59')))
    assert(!exp.include?(Time.parse('Friday 10 November 2006 17:31')))
  end

end
