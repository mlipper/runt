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

  # FIXME Refactor to TExpr-specific test 
  def test_union_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 12, 31)
    month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] 
    expr = DIMonth.new(Last, Friday) | DIMonth.new(First, Tuesday)
    dates = expr.dates(date_range)
    assert dates.size == 24
    dates.each do |d|
      unless (d.wday == 2 and d.day < 8) or \
	(d.wday == 5 and d.day > month_days[d.month-1] - 8)
        assert false, d.to_s 
      end
    end
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

  # FIXME Refactor to TExpr-specific test 
  def test_intersection_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 12, 31)
    expr = DIWeek.new(Sunday) & DIMonth.new(Second, Sunday)
    dates = expr.dates(date_range)
    assert( dates.size == 12 )
    other_dates = DIMonth.new(Second, Sunday).dates(date_range)
    dates.each { |d| assert( other_dates.include?(d) ) }
  end

  # FIXME Refactor to TExpr-specific test 
  def test_diff_dates
    date_range = Date.civil(2005, 1, 1)..Date.civil(2005, 1, 31)
    expr = REYear.new(1, 1, 1, 31) - REMonth.new(7, 15)
    dates = expr.dates(date_range)
    assert dates.size == 22, dates.size
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
  
end
