#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for TemporalExpression classes
# Author:: Matthew Lipper
class TemporalExpressionTest < Test::Unit::TestCase

  include Runt
  include DatePrecision

  def test_collection_te
    #base class that should always return false
    expr = CollectionTE.new
    assert(!expr.include?(Date.today))
  end

  def test_union_te
    #Test before adding expressions
    union_expr = UnionTE.new
    assert(!union_expr.include?(Date.today))
    #Everyday from midnight to 6:30am
    expr1 = RangeEachDayTE.new(0,0,6,30)
    #First Tuesday of the month
    expr2 = DayInMonthTE.new(First,Tuesday)
    union_expr.add(expr1).add(expr2)
    #January 6th, 2004 (First Tuesday)
    assert(union_expr.include?(TimePoint.day_of_month(2004,1,6)))
    #4am (February, 8th, 1966 - ignored)
    assert(union_expr.include?(TimePoint.hour_of_day(1966,2,8,4)))
    #6:31am, July, 4th, 2030
    assert(!union_expr.include?(TimePoint.minute(2030,7,4,6,31)))
  end

  def test_arbitrary_te
    expr1 = ArbitraryTE.new(TimePoint.day_of_month(2003,12,30))
    expr2 = ArbitraryTE.new(TimePoint.day_of_month(2004,1,1))
    assert(expr1.include?(Date.new(2003,12,30)))
    assert(!expr1.include?(Date.new(2003,12,31)))
    assert(expr2.include?(Date.new(2004,1,1)))
    assert(!expr2.include?(Date.new(2003,1,1)))
  end

  def test_arbitrary_range_te
    #NOTE:
    #Using standard range functionality like the following:
    #...  expr1 = ArbitraryRangeTE.new(r_start..r_end)
    #...  assert(expr1.include?((r_start+10)..(r_end-10)))
    #will work. However, it takes a LONG time to evaluate if range is large
    #and/or precision is small. Use DateRange instead

    r_start = TimePoint.second(2004,2,29,16,24,12)
    r_end = TimePoint.second(2004,3,2,4,22,58)
    #inclusive range equivalent to r_start..r_end
    expr1 = ArbitraryRangeTE.new(DateRange.new(r_start,r_end))
    assert(expr1.include?(TimePoint.second(2004,2,29,16,24,12)))
    assert(expr1.include?(TimePoint.second(2004,3,2,4,22,58)))
    assert(expr1.include?(DateTime.new(2004,3,1,23,00)))
    assert(!expr1.include?(DateTime.new(2004,3,2,4,22,59)))
    assert(!expr1.include?(Date.new(2003,3,1)))
    #exclusive range equivalent to r_start...r_end
    expr2 = ArbitraryRangeTE.new(DateRange.new(r_start,r_end,true))
    assert(expr2.include?(TimePoint.second(2004,2,29,16,24,12)))
    assert(!expr2.include?(TimePoint.second(2004,3,2,4,22,58)))
    r_sub = DateRange.new( (r_start+10), (r_end-10) )
    assert(expr1.include?(r_sub))
  end

  def test_intersection_te
    #Test before adding expressions
    intersect_expr  = IntersectionTE.new
    assert(!intersect_expr.include?(Date.today))
    #March through April
    expr1 = RangeEachYearTE.new(3,4)
    #First Sunday of any month
    expr2 = DayInMonthTE.new(First,Sunday)
    #Should match the first Sunday of March and April
    intersect_expr.add(expr1).add(expr2)
    #Sunday, March 7th, 2004
    assert(intersect_expr.include?(TimePoint.new(2004,3,7)))
    #First Sunday in February, 2004
    assert(!intersect_expr.include?(TimePoint.new(2004,4,1)))
  end

  def test_difference_te
    #8:30 pm to 12:00 midnight
    expr1 = RangeEachDayTE.new(20,30,00,00)
    #11:04 pm to 6:20 am
    expr2 = RangeEachDayTE.new(23,04,6,20)
    #Should match for 8:30 pm to 11:04 pm
    diff_expr  = DifferenceTE.new(expr1,expr2)
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
    expr1 = DayInMonthTE.new(Third,Friday)
    #second Friday of the month
    expr2 = DayInMonthTE.new(Second,Friday)
    assert(expr1.include?(dt1))
    assert(!expr1.include?(dt2))
    assert(expr2.include?(dt2))
    assert(!expr2.include?(dt1))
    #Sunday, January 25th 2004
    dt3 = Date.civil(2004,1,25)
    #last Sunday of the month
    expr3 = DayInMonthTE.new(Last_of,Sunday)
    assert(expr3.include?(dt3))
  end

  def test_day_in_week_te
    #Friday (woo-hoo!)
    expr = DayInWeekTE.new(Friday)
    #Friday, January 9th 2004
    assert(expr.include?(TimePoint.new(2004,1,9)))
    #Friday, January 16th 2004
    assert(expr.include?(TimePoint.new(2004,1,16)))
    #Monday, January 12th 2004
    assert(!expr.include?(TimePoint.new(2004,1,12)))
  end
  def test_week_in_month_te
    expr = WeekInMonthTE.new(Third)
    assert(expr.include?(TimePoint.day_of_month(2004,2,19)))
    assert(!expr.include?(TimePoint.day_of_month(2004,2,29)))
    expr2 = WeekInMonthTE.new(Last_of)
    assert(expr2.include?(TimePoint.day_of_month(2004,2,29)))
    expr3 = WeekInMonthTE.new(Second_to_last)
    assert(expr3.include?(TimePoint.day_of_month(2004,2,22)))
  end

  def test_range_each_year_te
    # November 1st, 1961
    dt1 = Date.civil(1961,11,1)
    #June, 1986
    dt2 = TimePoint::month(1986,6)
    #November and December
    expr1 = RangeEachYearTE.new(11,12)
    #May 31st through  and September 6th
    expr2 = RangeEachYearTE.new(5,31,9,6)
    assert(expr1.include?(dt1))
    assert(!expr1.include?(dt2))
    assert(expr2.include?(dt2))
  end

  def test_range_each_day_te
    #noon to 4:30pm
    expr1 = RangeEachDayTE.new(12,0,16,30)
    #3:15 pm (May 8th, 2012 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(2012,5,8,15,15)))
    #4:30 pm (April 18th, 1922 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(1922,4,18,16,30)))
    #noon (June 5th, 1975 - ignored)
    assert(expr1.include?(TimePoint.hour_of_day(1975,6,5,12,0)))
    #3:15 am (May 8th, 2012 - ignored)
    assert(!expr1.include?(TimePoint.hour_of_day(2012,5,8,3,15)))
    #8:30pm to 12:00 midnite
    expr2 = RangeEachDayTE.new(20,30,00,00)
    #9:00 pm (January 28th, 2004 - ignored)
    assert(expr2.include?(TimePoint.minute(2004,1,28,21,00)))
    #12:00 am (January 28th, 2004 - ignored)
    assert(expr2.include?(TimePoint.minute(2004,1,28,0,0)))
    #12:01 am (January 28th, 2004 - ignored)
    assert(!expr2.include?(TimePoint.minute(2004,1,28,0,01)))
  end

  def test_combined_te
    #Tuesdays
    tuesdays = DayInWeekTE.new(Tuesday)
    #Thursdays
    thursdays = DayInWeekTE.new(Thursday)
    #9:30 pm to midnight
    nine_thirty_to_midnight = RangeEachDayTE.new(21,30,00,00)
    #Last Monday
    last_monday = DayInMonthTE.new(Last,Monday)
    #First Monday
    first_monday = DayInMonthTE.new(First,Monday)

    #Memorial Day = last Monday of May
    memorial_day = IntersectionTE.new
    memorial_day.add(RangeEachYearTE.new(5)).add(DayInMonthTE.new(Last,Monday))

    #Labor Day = first Monday in September
    labor_day = IntersectionTE.new
    labor_day.add(RangeEachYearTE.new(9)).add(DayInMonthTE.new(First,Monday))

    #~ before=AnchoredBeforeTE.new(labor_day,true)
    #~ puts before.include?(TimePoint.minute(2004,5,8,0,01))

    #All Summer long!
    summer_time = IntersectionTE.new



  end


end
