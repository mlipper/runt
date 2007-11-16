#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for REMonth class
# Author:: Matthew Lipper

class REMonthTest < BaseExpressionTest


  def test_20th_thru_29th_of_every_month
   expr = REMonth.new(20,29)
   assert expr.include?(@date_20050123), "Expression #{expr.to_s} should include #{@date_20050123.to_s}" 
   assert !expr.include?(@date_20050116), "Expression #{expr.to_s} should not include #{@date_20050116.to_s}"
  end

  def test_16th_of_every_month
   expr = REMonth.new(16)
   assert expr.include?(@date_20050116), "Expression #{expr.to_s} should include #{@date_20050116.to_s}"
   assert !expr.include?(@date_20050123), "Expression #{expr.to_s} should not include #{@date_20050123.to_s}"
  end
  
  def test_dates_mixin
    expr = REMonth.new(22, 26)
    dates = expr.dates(@pdate_20071024..@pdate_20071028)
    assert dates.size == 3, "Expected 2 dates and got #{dates.size}"
    # Use default Test::Unit assertion message
    assert_equal "2007-10-24T00:00:00+00:00", dates[0].to_s
    assert_equal "2007-10-25T00:00:00+00:00", dates[1].to_s
    assert_equal "2007-10-26T00:00:00+00:00", dates[2].to_s
  end
  
  def test_range_each_month_to_s
    assert_equal 'from the 2nd to the 5th monthly',REMonth.new(2,5).to_s
  end
  
end
