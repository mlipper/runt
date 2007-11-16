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

end
