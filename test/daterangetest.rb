#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for DateRange class
#
# Author:: Matthew Lipper
class DateRangeTest < Test::Unit::TestCase

  include Runt

  def test_sub_range
    r_start = PDate.sec(2004,2,29,16,24,12)
    r_end = PDate.sec(2004,3,2,4,22,58)
    range = DateRange.new(r_start,r_end)
    assert(range.min==r_start)
    assert(range.max==r_end)
    assert(range.include?(r_start+1))
    assert(range.include?(r_end-1))
    sub_range = DateRange.new((r_start+1),(r_end-1))
    assert(range.include?(sub_range))
  end

  def test_date
    r_start = PDate.min(1979,12,31,23,57)
    r_end = PDate.min(1980,1,1,0,2)
    range = DateRange.new(r_start,r_end)
    assert(range.min==r_start)
    assert(range.max==r_end)
    assert(range.include?(r_start+1))
    assert(range.include?(r_end-1))
    sub_range = DateRange.new((r_start+1),(r_end-1))
    assert(range.include?(sub_range))
  end

  def test_spaceship_operator
    r_start = PDate.min(1984,8,31,22,00)
    r_end = PDate.min(1984,9,15,0,2)
    range = DateRange.new(r_start,r_end)
    assert(-1==(range<=>(DateRange.new(r_start+2,r_end+5))))
    assert(1==(range<=>(DateRange.new(r_start-24,r_end+5))))
    assert(0==(range<=>(DateRange.new(r_start,r_end))))
  end

  def test_overlap
    r_start = PDate.month(2010,12)
    r_end = PDate.month(2011,12)
    range = DateRange.new(r_start,r_end)
    o_start = PDate.month(2010,11)
    o_end = PDate.month(2012,2)
    o_range = DateRange.new(o_start,o_end)
    assert(range.overlap?(o_range))
    assert(o_range.overlap?(range))
    assert(o_range.overlap?(DateRange.new(r_start,o_end)))
    assert(o_range.overlap?(DateRange.new(o_start,r_end)))
        
    # September 18th - 19th, 2005, 8am - 10am 
    expr1=DateRange.new(PDate.day(2005,9,18),PDate.day(2005,9,19)) 
    # September 19th - 20th, 2005, 9am - 11am 
    expr2=DateRange.new(PDate.day(2005,9,19),PDate.day(2005,9,20))

    assert(expr1.overlap?(expr2))
  end

  def test_empty
    r_start = PDate.hour(2004,2,10,0)
    r_end = PDate.hour(2004,2,9,23)
    empty_range = DateRange.new(r_start,r_end)
    assert(empty_range.empty?)
    assert(DateRange::EMPTY.empty?)
  end

  def test_gap
    r_start = PDate.day(2000,6,12)
    r_end = PDate.day(2000,6,14)
    range = DateRange.new(r_start,r_end)
    g_start = PDate.day(2000,6,18)
    g_end = PDate.day(2000,6,20)
    g_range = DateRange.new(g_start,g_end)
    the_gap=range.gap(g_range)
    assert(the_gap.start_expr==(r_end+1))
    assert(the_gap.end_expr==(g_start-1))
  end

end
