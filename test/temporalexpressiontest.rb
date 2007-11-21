#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for TExpr classes
# Author:: Matthew Lipper

class TExprTest < BaseExpressionTest


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

end
