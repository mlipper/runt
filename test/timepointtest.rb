  #!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'date'
require 'runt'

# Unit tests for TimePoint class
# Author:: Matthew Lipper
class TimePointTest < Test::Unit::TestCase

  include Runt

  def setup
    # 2010 (August - ignored)
    @year_prec = TimePoint.year(2010,8)
    #August, 2004
    @month_prec = TimePoint.month(2004,8)
    #January 25th, 2004 (11:39 am - ignored)
    @day_prec = TimePoint.day_of_month(2004,1,25,11,39)
    #11:59(:04 - ignored), December 31st, 1999
    @minute_prec = TimePoint.minute(1999,12,31,23,59,4)
    #12:00:10 am, March 1st, 2004
    @second_prec = TimePoint.second(2004,3,1,0,0,10)
  end

  def test_new
    date = TimePoint.new(2004,2,29)
    assert(!date.date_precision.nil?)
    date_time = TimePoint.new(2004,2,29,22,13,2)
    assert(!date_time.date_precision.nil?)

    date2 = TimePoint.day_of_month(2004,2,29)
    assert(date==date2)

    date_time2 = TimePoint.second(2004,2,29,22,13,2)
    assert(date_time==date_time2)

  end

  def test_plus
    assert(TimePoint.year(2022,12)==(@year_prec+12))
    assert(TimePoint.month(2005,2)==(@month_prec+6))
    assert(TimePoint.day_of_month(2004,2,1)==(@day_prec+7))
    assert(TimePoint.minute(2000,1,1,0,0)==(@minute_prec+1))
    assert(TimePoint.second(2004,3,1,0,0,21)==(@second_prec+11))
  end

  def test_minus
    assert(TimePoint.year(1998,12)==(@year_prec-12))
    assert(TimePoint.month(2002,6)==(@month_prec-26))
    #Hmmm...FIXME? @day_prec-26 == 12/31??
    assert(TimePoint.day_of_month(2003,12,30)==(@day_prec-26))
    assert(TimePoint.minute(1999,12,31,21,57)==(@minute_prec-122))
    assert(TimePoint.second(2004,2,29,23,59,59)==(@second_prec-11))
  end

  def test_range
    #11:50 pm (:22 seconds ignored), February 2nd, 2004
    min1 = TimePoint.minute(2004,2,29,23,50,22)
    #12:02 am , March 1st, 2004
    min2 = TimePoint.minute(2004,3,1,0,2)
    #Inclusive Range w/minute precision
    r_min = min1..min2

    assert( r_min.include?(TimePoint.minute(2004,3,1,0,0)) )
    assert( ! r_min.include?(TimePoint.minute(2004,3,1,0,3)) )

    #~ r_min.each do |date|
      #~ puts date.ctime
    #~ end
  end

  def test_create_with_class_methods
    #December 12th, 1968
    no_prec = TimePoint.civil(1968,12,12)
    #December 12th, 1968 (at 11:15 am - ignored)
    day_prec = TimePoint.day_of_month(1968,12,12,11,15)
    assert(no_prec==day_prec, "TimePoint instance does not equal precisioned instance.")
    #December 2004 (24th - ignored)
    month_prec1 = TimePoint.month(2004,12,24)
    #December 31st, 2004  (31st - ignored)
    month_prec2 = TimePoint.month(2004,12,31)
    assert(month_prec1==month_prec2, "TimePoint.month instances not equal.")
    #December 2004
    month_prec3 = TimePoint.month(2004,12)
    assert(month_prec1==month_prec3, "TimePoint.month instances not equal.")
    assert(month_prec2==month_prec3, "TimePoint.month instances not equal.")
    #December 2003
    month_prec4 = TimePoint.month(2003,12)
    assert(month_prec4!=month_prec1, "TimePoint.month instances not equal.")
  end
end