#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for DateRange class
#
# Author:: Matthew Lipper
class DateRangeTest < Test::Unit::TestCase

  include Runt

  def test_sub_range
    r_start = TimePoint.second(2004,2,29,16,24,12)
    r_end = TimePoint.second(2004,3,2,4,22,58)
    range = DateRange.new(r_start,r_end)
    assert(range.min==r_start)
    assert(range.max==r_end)
    assert(range.include?(r_start+1))
    assert(range.include?(r_end-1))
    sub_range = DateRange.new((r_start+1),(r_end-1))
    assert(range.include?(sub_range))
  end

  def test_date
    r_start = TimePoint.minute(1979,12,31,23,57)
    r_end = TimePoint.minute(1980,1,1,0,2)
    range = DateRange.new(r_start,r_end)
    assert(range.min==r_start)
    assert(range.max==r_end)
    assert(range.include?(r_start+1))
    assert(range.include?(r_end-1))
    sub_range = DateRange.new((r_start+1),(r_end-1))
    assert(range.include?(sub_range))
  end

  def test_spaceship_operator
    r_start = TimePoint.minute(1984,8,31,22,00)
    r_end = TimePoint.minute(1984,9,15,0,2)
    range = DateRange.new(r_start,r_end)		
		assert(-1==(range<=>(DateRange.new(r_start+2,r_end+5))))
		assert(1==(range<=>(DateRange.new(r_start-24,r_end+5))))
		assert(0==(range<=>(DateRange.new(r_start,r_end))))
  end

  def test_overlap
    r_start = TimePoint.month(2010,12)
    r_end = TimePoint.month(2011,12)
    range = DateRange.new(r_start,r_end)
		o_start = TimePoint.month(2010,11)
    o_end = TimePoint.month(2012,2)
		o_range = DateRange.new(o_start,o_end)
		assert(range.overlap?(o_range)) 
		assert(o_range.overlap?(range)) 
		assert(o_range.overlap?(DateRange.new(r_start,o_end))) 
		assert(o_range.overlap?(DateRange.new(o_start,r_end)))
  end
end