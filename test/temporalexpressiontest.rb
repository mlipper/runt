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
  
  # DIMonth tests moved to dimonthtest.rb
  def test_day_in_week_te
    #Friday (woo-hoo!)
    expr = DIWeek.new(Friday)
    #Friday, January 9th 2004
    assert(expr.include?(PDate.new(2004,1,9)))
    #Friday, January 16th 2004
    assert(expr.include?(PDate.new(2004,1,16)))
    #Monday, January 12th 2004
    assert(!expr.include?(PDate.new(2004,1,12)))
  end
  
  def test_day_in_week_te_to_s
    assert_equal 'Friday', DIWeek.new(Friday).to_s
  end
    
  def test_week_in_month_te
    expr = WIMonth.new(Third)
    assert(expr.include?(PDate.day(2004,2,19)))
    assert(!expr.include?(PDate.day(2004,2,29)))
    expr2 = WIMonth.new(Last_of)
    assert(expr2.include?(PDate.day(2004,2,29)))
    expr3 = WIMonth.new(Second_to_last)
    assert(expr3.include?(PDate.day(2004,2,22)))
  end

  # REYear tests moved to reyeartest.rb!

  def test_range_each_day_te
    #noon to 4:30pm
    expr1 = REDay.new(12,0,16,30)
    #3:15 pm (May 8th, 2012 - ignored)
    assert(expr1.include?(PDate.hour(2012,5,8,15,15)))
    #4:30 pm (April 18th, 1922 - ignored)
    assert(expr1.include?(PDate.hour(1922,4,18,16,30)))
    #noon (June 5th, 1975 - ignored)
    assert(expr1.include?(PDate.hour(1975,6,5,12,0)))
    #3:15 am (May 8th, 2012 - ignored)
    assert(!expr1.include?(PDate.hour(2012,5,8,3,15)))
    #8:30pm to 12:00 midnite
    expr2 = REDay.new(20,30,00,00)
    #9:00 pm (January 28th, 2004 - ignored)
    assert(expr2.include?(PDate.min(2004,1,28,21,00)))
    #12:00 am (January 28th, 2004 - ignored)
    assert(expr2.include?(PDate.min(2004,1,28,0,0)))
    #12:01 am (January 28th, 2004 - ignored)
    assert(!expr2.include?(PDate.min(2004,1,28,0,01)))
  end

  # Commenting this out; not sure what's being tested exactly
  #def test_range_each_day_te_again
  #  dr = DateRange.new(PDate.day(2005,9,19),PDate.day(2005,9,20))
  #  red = REDay.new(8,0,10,0)
  #  result = false
  #  dr.each do |interval|
  #    result = red.include?(interval)
  #    break if result
  #  end      
  #  assert(result)
  #end
  
  # From bug #5749 
  def test_range_each_day_te_fun_with_precision
    # range of time from 10.00 to 10.01
    ten_ish = REDay.new(10,0,10,1)
    # 21st of September every year
    every_21_sept = REYear.new(9,21,9,21)
    # combination expression (between 10.00 and 10.01 every 21st September)
    combo = ten_ish & every_21_sept
    assert(!combo.include?(PDate.new(2006,9,21)), "Should not include lower precision argument")
    assert(combo.include?(PDate.new(2006,9,21,10,0,1)),
           "Should include higher precision argument which is in range")
    assert(!combo.include?(PDate.new(2006,9,21,10,2)),
           "Should not include matching pecision argument which is out of range")
  end

  def test_range_each_day_te_to_s
    assert_equal 'from 11:10PM to 01:20AM daily', REDay.new(23,10,1,20).to_s
  end
  
  def test_range_each_week_te
    assert_raises(ArgumentError){ expr = REWeek.new(10,4) }
    expr1 = REWeek.new(Mon,Fri) & REDay.new(8,00,8,30)
    assert(!expr1.include?(PDate.new(2004,5,1,8,06)))
    #Sunday through Thursday
    expr2 = REWeek.new(0,4)
    assert(expr2.include?(PDate.min(2004,2,19,23,59,59)))
    assert(!expr2.include?(PDate.min(2004,2,20,0,0,0)))
  end
  
  def test_range_each_week_te
    #Friday through Tuesday
     expr = Runt::REWeek.new(5,2) 

     assert   expr.include?(Time.mktime(2007,9,28,0,0,0)),   "#{expr.inspect} should include Fri 12am"
     assert   expr.include?(Time.mktime(2007,9,25,11,59,59)),"#{expr.inspect} should include Tue 11:59pm"
     assert ! expr.include?(Time.mktime(2007,9,26,0,0,0)),  "#{expr.inspect} should not include Wed 12am"
     assert ! expr.include?(Time.mktime(2007,9,27,6,59,59)), "#{expr.inspect} should not include Thurs 6:59am"
     assert ! expr.include?(Time.mktime(2007,9,27,11,59,0)), "#{expr.inspect} should not include Thurs 1159am"
     assert   expr.include?(Time.mktime(2007,9,29,11,0,0)),  "#{expr.inspect} should include Sat 11am"
     assert   expr.include?(Time.mktime(2007,9,29,0,0,0)),   "#{expr.inspect} should include Sat midnight"
     assert   expr.include?(Time.mktime(2007,9,29,23,59,59)), "#{expr.inspect} should include Saturday one minute before midnight"
     assert   expr.include?(Time.mktime(2007,9,30,23,59,59)), "#{expr.inspect} should include Sunday one minute before midnight"
  end
  
  def test_range_each_week_te_to_s
    assert_equal 'all week', REWeek.new(Tuesday,Tuesday).to_s
    assert_equal 'Thursday through Saturday', REWeek.new(Thursday,Saturday).to_s
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

 def test_re_month_te
   # October 22nd, 2005
   dt1 = Date.civil(2005,10,22)
   # The 20th through the 29th of any month
   expr1 = REMonth.new(20,29)
   assert(expr1.include?(dt1))
   assert(!expr1.include?(PDate.new(2010,12,12)))
   # August 17th, 1975
   dt2 = Date.civil(1975,8,17)
   # The 17th of any month
   expr2 = REMonth.new(17)
   assert(expr2.include?(dt2))
   assert(!expr2.include?(dt1))
  end
  
  def test_day_in_week_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 1, 31)
    expr = DIWeek.new(Sunday)
    dates = expr.dates(date_range)
    assert( dates.size == 5 )
    assert( dates.include?( Date.civil(2005, 1, 16) ) )
    assert( dates.include?( Date.civil(2005, 1, 30) ) )
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

  def test_range_each_week_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 1, 31)
    expr = REWeek.new(3, 5)
    dates = expr.dates(date_range)
    assert dates.size == 12
  end

  def test_week_in_month_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 2, 28)
    expr = WIMonth.new(2)
    dates = expr.dates(date_range)
    assert dates.size == 14, dates.size
    assert dates.first.mday == 8
    assert dates.last.mday == 14
    expr_2 = WIMonth.new(Last)
    dates_2 = expr_2.dates(date_range)
    assert dates_2.size == 14, dates_2.size
    assert dates_2.first.mday == 25
    assert dates_2.last.mday == 28
  end

  def test_week_in_month_to_s
    assert_equal 'last week of any month', WIMonth.new(Last).to_s
  end

  def test_range_each_month_dates
    date_range = Date.civil(2005, 1, 7)..Date.civil(2005, 1, 15)
    expr = REMonth.new(5, 9)
    dates = expr.dates(date_range)
    assert dates.size == 3, dates.size
    assert false if dates.include? Date.civil(2005, 1, 6)
  end
  
  def test_range_each_month_to_s
    assert_equal 'from the 2nd to the 5th monthly',REMonth.new(2,5).to_s
  end
  
  def test_diff_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 1, 31)
    expr = REYear.new(1, 1, 1, 31) - REMonth.new(7, 15)
    dates = expr.dates(date_range)
    assert dates.size == 22, dates.size
  end

  def test_day_interval_te
    date1 = Date.civil(2005,10,28)
    # Match every 8 days
    expr = DayIntervalTE.new(date1, 8)
    assert expr.include?((date1 + 8))
    assert expr.include?((date1 + 16))
    assert expr.include?((date1 + 64))
    # Now use DateTime
    date2 = DateTime.now
    # Match every 6 days
    expr2 = DayIntervalTE.new(date2, 6)
    assert expr2.include?((date2 + 12))
    assert expr2.include?((date2 + 24))
  end
  
  def test_day_interval_te_to_s
    every_four_days = DayIntervalTE.new(Date.new(2006,2,26), 4)
    assert_equal "every 4th day after #{Runt.format_date(Date.new(2006,2,26))}", every_four_days.to_s
  end
  
  def test_year_te
    # second sun of any month 
    second_sun = DIMonth.new(Second, Sunday)
    # simple year matching expression which will return true for
    # any date in 2005
    year_te = YearTE.new(2005)
    # Second Sunday of a month in 2002
    dt_in_2002 = Date.civil(2002,9,8)
    # Second Sunday of a month in 2005
    dt_in_2005 = Date.civil(2005,12,11)
    assert(year_te.include?(dt_in_2005))
    assert(!year_te.include?(dt_in_2002))
  end

  def test_year_te
    assert_equal 'during the year 1934', YearTE.new(1934).to_s
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

  def test_every_te_minutes
    # Match every 2 minutes
    xpr=EveryTE.new(PDate.min(2006,12,5,5,54), 2)
    assert !xpr.include?(PDate.min(2006,12,4,5,54))
    assert xpr.include?(PDate.min(2006,12,5,5,54))
    assert xpr.include?(PDate.min(2006,12,5,5,56))
    assert xpr.include?(PDate.sec(2006,12,5,5,58,03))
    assert xpr.include?(PDate.min(2006,12,5,6,00))
    assert !xpr.include?(PDate.min(2006,12,5,5,59))
    assert xpr.include?(Time.parse('Tuesday 05 December 2006 07:08'))
    # Match every 3 days
    xpr2=EveryTE.new(PDate.day(2006,5,4), 3)
    assert !xpr2.include?(Date.new(2006,5,5))
    assert !xpr2.include?(PDate.new(2006,5,6))
    assert xpr2.include?(PDate.new(2006,5,7))
    assert xpr2.include?(PDate.min(2006,5,10,6,45))
  end
  
  def test_every_te_days
    dstart = DateTime.parse("US-Eastern:19970902T090000")
    dstart.date_precision = DPrecision::DAY
    
    xpr=EveryTE.new(dstart, 10) & REWeek.new(Sun,Sat)
    
    assert !xpr.include?(DateTime.parse("US-Eastern:19970901T090000")) #Sep 1
    assert xpr.include?(DateTime.parse("US-Eastern:19970902T090000")) #Sep 2
    assert !xpr.include?(DateTime.parse("US-Eastern:19970904T090000")) #Sep 3
    assert !xpr.include?(DateTime.parse("US-Eastern:19970904T090000")) #Sep 4
    assert !xpr.include?(DateTime.parse("US-Eastern:19970905T090000")) #Sep 5
    assert !xpr.include?(DateTime.parse("US-Eastern:19970906T090000")) #Sep 6
    assert !xpr.include?(DateTime.parse("US-Eastern:19970907T090000")) #Sep 7
    assert !xpr.include?(DateTime.parse("US-Eastern:19970908T090000")) #Sep 8
    assert !xpr.include?(DateTime.parse("US-Eastern:19970909T090000")) #Sep 9
    assert !xpr.include?(DateTime.parse("US-Eastern:19970910T090000")) #Sep 10
    assert !xpr.include?(DateTime.parse("US-Eastern:19970911T090000")) #Sep 11
    assert xpr.include?(DateTime.parse("US-Eastern:19970912T090000")) #Sep 12
    assert xpr.include?(DateTime.parse("US-Eastern:19970922T090000")) #Sep 22
    assert xpr.include?(DateTime.parse("US-Eastern:19971002T090000")) #Oct 2
    assert xpr.include?(DateTime.parse("US-Eastern:19971012T090000")) #Oct 12
  end
  
  def test_every_te_to_s
    date=PDate.new(2006,12,5,6,0,0)
    every_thirty_seconds=EveryTE.new(date, 30)
    assert_equal "every 30 seconds starting #{Runt.format_date(date)}", every_thirty_seconds.to_s
  end
  
end
