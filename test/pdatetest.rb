  #!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'date'
require 'runt'

# Unit tests for PDate class
# Author:: Matthew Lipper
class PDateTest < Test::Unit::TestCase

  include Runt

  def setup
    # 2010 (August - ignored)
    @year_prec = PDate.year(2010,8)
    #August, 2004
    @month_prec = PDate.month(2004,8)
    #January 25th, 2004 (11:39 am - ignored)
    @day_prec = PDate.day(2004,1,25,11,39)
    #11:59(:04 - ignored), December 31st, 1999
    @minute_prec = PDate.min(1999,12,31,23,59,4)
    #12:00:10 am, March 1st, 2004
    @second_prec = PDate.sec(2004,3,1,0,0,10)
  end

  def test_new
    date = PDate.new(2004,2,29)
    assert(!date.date_precision.nil?)
    date_time = PDate.new(2004,2,29,22,13,2)
    assert(!date_time.date_precision.nil?)

    date2 = PDate.day(2004,2,29)
    assert(date==date2)

    date_time2 = PDate.sec(2004,2,29,22,13,2)
    assert(date_time==date_time2)

  end

  def test_plus
    assert(PDate.year(2022,12)==(@year_prec+12))
    assert(PDate.month(2005,2)==(@month_prec+6))
    assert(PDate.day(2004,2,1)==(@day_prec+7))
    assert(PDate.min(2000,1,1,0,0)==(@minute_prec+1))
    assert(PDate.sec(2004,3,1,0,0,21)==(@second_prec+11))
  end

  def test_minus
    assert(PDate.year(1998,12)==(@year_prec-12))
    assert(PDate.month(2002,6)==(@month_prec-26))
    #Hmmm...FIXME? @day_prec-26 == 12/31??
    assert(PDate.day(2003,12,30)==(@day_prec-26))
    assert(PDate.min(1999,12,31,21,57)==(@minute_prec-122))
    assert(PDate.sec(2004,2,29,23,59,59)==(@second_prec-11))
  end
  def test_spaceship_comparison_operator
    sec_prec = PDate.sec(2002,8,28,6,04,02)
    assert(PDate.year(1998,12)<sec_prec)
    assert(PDate.month(2002,9)>sec_prec)
    assert(PDate.day(2002,8,28)==sec_prec)
    assert(PDate.min(1999,12,31,21,57)<sec_prec)
    assert(DateTime.new(2002,8,28,6,04,02)==sec_prec)
    assert(Date.new(2004,8,28)>sec_prec)
  end
  def test_succ
    #~ fail("FIXME! Implement succ")
  end
  def test_range
    #11:50 pm (:22 seconds ignored), February 2nd, 2004
    min1 = PDate.min(2004,2,29,23,50,22)
    #12:02 am , March 1st, 2004
    min2 = PDate.min(2004,3,1,0,2)
    #Inclusive Range w/minute precision
    r_min = min1..min2
    assert( r_min.include?(PDate.min(2004,2,29,23,50,22)) )
    assert( r_min.include?(PDate.min(2004,3,1,0,2)) )
    assert( r_min.include?(PDate.min(2004,3,1,0,0)) )
    assert( ! r_min.include?(PDate.min(2004,3,1,0,3)) )
    #Exclusive Range w/minute precision
    r_min = min1...min2
    assert( r_min.include?(PDate.min(2004,2,29,23,50,22)) )
    assert( !r_min.include?(PDate.min(2004,3,1,0,2)) )
  end

  def test_create_with_class_methods
    #December 12th, 1968
    no_prec = PDate.civil(1968,12,12)
    #December 12th, 1968 (at 11:15 am - ignored)
    day_prec = PDate.day(1968,12,12,11,15)
    assert(no_prec==day_prec, "PDate instance does not equal precisioned instance.")
    #December 2004 (24th - ignored)
    month_prec1 = PDate.month(2004,12,24)
    #December 31st, 2004  (31st - ignored)
    month_prec2 = PDate.month(2004,12,31)
    assert(month_prec1==month_prec2, "PDate.month instances not equal.")
    #December 2004
    month_prec3 = PDate.month(2004,12)
    assert(month_prec1==month_prec3, "PDate.month instances not equal.")
    assert(month_prec2==month_prec3, "PDate.month instances not equal.")
    #December 2003
    month_prec4 = PDate.month(2003,12)
    assert(month_prec4!=month_prec1, "PDate.month instances not equal.")
  end
end
