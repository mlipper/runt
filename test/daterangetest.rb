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

end