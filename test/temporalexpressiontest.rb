#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

$DEBUG=false

# Unit tests for TExpr classes
# Author:: Matthew Lipper
class TExprTest < Test::Unit::TestCase

  include Runt
  include DatePrecision

  def test_collection_te
    #base class that should always return false
    expr = Collection.new
    assert(!expr.include?(Date.today))
  end

  def test_union_te
    #midnight to 6:30am AND/OR first Tuesday of the month
    expr = RgEaDy.new(0,0,6,30) | DyInMn.new(First,Tuesday)
    assert(expr.include?(TimePoint.day_of_month(2004,1,6))) #January 6th, 2004 (First Tuesday)
    assert(expr.include?(TimePoint.hour_of_day(1966,2,8,4))) #4am (February, 8th, 1966 - ignored)
    assert(!expr.include?(TimePoint.minute(2030,7,4,6,31))) #6:31am, July, 4th, 2030
  end

  def test_arbitrary_te
    expr1 = Arbitrary.new(TimePoint.day_of_month(2003,12,30))
    expr2 = Arbitrary.new(TimePoint.day_of_month(2004,1,1))
    assert(expr1.include?(Date.new(2003,12,30)))
    assert(!expr1.include?(Date.new(2003,12,31)))
    assert(expr2.include?(Date.new(2004,1,1)))
    assert(!expr2.include?(Date.new(2003,1,1)))
  end

  def test_arbitrary_range_te
    #NOTE:
    #Using standard range functionality like the following:
    #...  expr1 = ArbitraryRange.new(r_start..r_end)
    #...  assert(expr1.include?((r_start+10)..(r_end-10)))
    #will work. However, it takes a LONG time to evaluate if range is large
    #and/or precision is small. Use DateRange instead

    r_start = TimePoint.second(2004,2,29,16,24,12)
    r_end = TimePoint.second(2004,3,2,4,22,58)
    #inclusive range equivalent to r_start..r_end
    expr1 = ArbitraryRange.new(DateRange.new(r_start,r_end))
    assert(expr1.include?(TimePoint.second(2004,2,29,16,24,12)))
    assert(expr1.include?(TimePoint.second(2004,3,2,4,22,58)))
    assert(expr1.include?(DateTime.new(2004,3,1,23,00)))
    assert(!expr1.include?(DateTime.new(2004,3,2,4,22,59)))
    assert(!expr1.include?(Date.new(2003,3,1)))
    #exclusive range equivalent to r_start...r_end
    expr2 = ArbitraryRange.new(DateRange.new(r_start,r_end,true))
    assert(expr2.include?(TimePoint.second(2004,2,29,16,24,12)))
    assert(!expr2.include?(TimePoint.second(2004,3,2,4,22,58)))
    r_sub = DateRange.new( (r_start+10), (r_end-10) )
    assert(expr1.include?(r_sub))
  end

  def test_intersection_te
    #Should match the first Sunday of March and April
    intersect_expr  = RgEaYr.new(3,4) & DyInMn.new(First,Sunday)
    assert(intersect_expr.include?(TimePoint.new(2004,3,7))) #Sunday, March 7th, 2004
    assert(!intersect_expr.include?(TimePoint.new(2004,4,1))) #First Sunday in February, 2004
  end

  def test_difference_te
    #Should match for 8:30 pm to 11:04 pm
    diff_expr  = RgEaDy.new(20,30,00,00) - RgEaDy.new(23,04,6,20)
    #8:45 pm (May 1st, 2003 - ignored)
    assert(diff_expr.include?(TimePoint.new(2003,5,1,20,45)))
    #11:05 pm (February 1st, 2004 - ignored)
    assert(!diff_expr.include?(TimePoint.new(2004,2,1,23,05)))
    #8:00 pm (May 1st, 2003 - ignored)
    assert(!diff_expr.include?(TimePoint.new(2003,5,1,20,00)))
  end

  def test_day_in_month_te
    #Friday, January 16th 2004
    dt1 = Date.civil(2004,1,16)
    #Friday, January 9th 2004
    dt2 = Date.civil(2004,1,9)
    #third Friday of the month
    expr1 = DyInMn.new(Third,Friday)
    #second Friday of the month
    expr2 = DyInMn.new(Second,Friday)
    assert(expr1.include?(dt1))
    assert(!expr1.include?(dt2))
    assert(expr2.include?(dt2))
    assert(!expr2.include?(dt1))
    #Sunday, January 25th 2004
    dt3 = Date.civil(2004,1,25)
    #last Sunday of the month
    expr3 = DyInMn.new(Last_of,Sunday)
    assert(expr3.include?(dt3))
  end

  def test_day_in_week_te
    #Friday (woo-hoo!)
    expr = DyInWk.new(Friday)
    #Friday, January 9th 2004
    assert(expr.include?(TimePoint.new(2004,1,9)))
    #Friday, January 16th 2004
    assert(expr.include?(TimePoint.new(2004,1,16)))
    #Monday, January 12th 2004
    assert(!expr.include?(TimePoint.new(2004,1,12)))
  end
  def test_week_in_month_te
    expr = WkInMn.new(Third)
    assert(expr.include?(TimePoint.day_of_month(2004,2,19)))
    assert(!expr.include?(TimePoint.day_of_month(2004,2,29)))
    expr2 = WkInMn.new(Last_of)
    assert(expr2.include?(TimePoint.day_of_month(2004,2,29)))
    expr3 = WkInMn.new(Second_to_last)
    assert(expr3.include?(TimePoint.day_of_month(2004,2,22)))
  end

  def test_range_each_year_te
    # November 1st, 1961
    dt1 = Date.civil(1961,11,1)
    #June, 1986
    dt2 = TimePoint::month(1986,6)
    #November and December
    expr1 = RgEaYr.new(11,12)
    #May 31st through  and September 6th
    expr2 = RgEaYr.new(5,31,9,6)
    assert(expr1.include?(dt1))
    assert(!expr1.include?(dt2))
    assert(expr2.include?(dt2))
    #August
    expr3 = RgEaYr.new(8)
    assert(!expr3.include?(dt1))
    assert(!expr3.include?(dt2))
    #August 6th, 2004
    dt3 = Date::new(2004,8,6)
    assert(expr3.include?(dt3))
  end

  def test_range_each_day_te
    #noon to 4:30pm
    expr1 = RgEaDy.new(12,0,16,30)
    #3:15 pm (May 8th, 2012 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(2012,5,8,15,15)))
    #4:30 pm (April 18th, 1922 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(1922,4,18,16,30)))
    #noon (June 5th, 1975 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(1975,6,5,12,0)))
    #3:15 am (May 8th, 2012 - ignored)
    assert(!expr1.include?(TimePoint.hour_of_day(2012,5,8,3,15)))
    #8:30pm to 12:00 midnite
    expr2 = RgEaDy.new(20,30,00,00)
    #9:00 pm (January 28th, 2004 - ignored)
    assert(expr2.include?(TimePoint.minute(2004,1,28,21,00)))
    #12:00 am (January 28th, 2004 - ignored)
    assert(expr2.include?(TimePoint.minute(2004,1,28,0,0)))
    #12:01 am (January 28th, 2004 - ignored)
    assert(!expr2.include?(TimePoint.minute(2004,1,28,0,01)))
  end
  def test_range_each_week_te
		begin
			expr = RgEaWk.new(10,4)
			fail "ArgumentError expected"
		rescue ArgumentError
			#Expected, YAY! we passed! YAY!
		end
		#Sunday through Thursday
		expr2 = RgEaWk.new(0,4)
    assert(expr2.include?(TimePoint.minute(2004,2,19,23,59,59)))
    assert(!expr2.include?(TimePoint.minute(2004,2,20,0,0,0)))
	end
  def test_combined_te
		#This is a hack.....
		#In the U.S., Memorial Day begins the last Monday of May
		#
		#The month of May
		may=RgEaYr.new(5)
		#Monday through Saturday
		monday_to_saturday = RgEaWk.new(1,6)
		#Last week of (any) month
		last_week_in = WkInMn.new(Last_of)
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
		september=RgEaYr.new(9)
		#First week of (any) month
		first_week_in = WkInMn.new(First)
    entire_first_week_of_september = september & first_week_in
    #To exclude everything in the first week which occurs on or after Monday.
    first_week_of_september=entire_first_week_of_september - monday_to_saturday
    #June through August
		june_through_august=RgEaYr.new(6,First,8)
    assert(june_through_august.include?(TimePoint.day_of_month(2004,7,4)))
    #Finally!
    summer_time = last_week_of_may | first_week_of_september | june_through_august

    #Will work, but will be incredibly slow:
    #  assert(summer_time.include?(TimePoint.minute(2004,5,31,0,0)))
    assert(summer_time.include?(TimePoint.day_of_month(2004,5,31,0,0)))
    assert(summer_time.include?(TimePoint.day_of_month(2004,7,4)))
    #also works...also slow:
    #  assert(!summer_time.include?(TimePoint.minute(2004,9,6,0,0)))
    assert(!summer_time.include?(TimePoint.hour_of_day(2004,9,6,0,0)))

  end
  def test_nyc_parking_te

    #Monday, Wednesday, Friday
    mon_wed_fri = DyInWk.new(Monday) | \
                    DyInWk.new(Wednesday) | \
                      DyInWk.new(Friday)


    #Wednesday (at 7:15pm - ignored)
    assert(mon_wed_fri.include?(DateTime.new(2004,3,10,19,15)))

    #Sunday (at 9:00am - ignored)
    assert(!mon_wed_fri.include?(DateTime.new(2004,3,14,9,00)))

    #8am to 11am
    eight_to_eleven = RgEaDy.new(8,00,11,00)

    #=> Mon,Wed,Fri - 8am to 11am
    expr1 = mon_wed_fri & eight_to_eleven

    #Tuesdays, Thursdays
    tues_thurs = DyInWk.new(Tuesday) | DyInWk.new(Thursday)

    #11:30am to 2pm
    eleven_thirty_to_two = RgEaDy.new(11,30,14,00)

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

 end

end
