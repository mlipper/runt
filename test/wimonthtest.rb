#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for WIMonth class
# Author:: Matthew Lipper

class WIMonthTest < BaseExpressionTest

  def setup
    super
    @date_range = @date_20050101..@date_20050228
  end


  def test_second_week_in_month
    expr = WIMonth.new(Second)
    assert expr.include?(@pdate_20071008), "#{expr.to_s} should include #{@pdate_20071008.to_s}"
    assert !expr.include?(@pdate_20071030), "#{expr.to_s} should not include #{@pdate_20071030.to_s}"
  end

  def test_last_week_in_month 
    expr = WIMonth.new(Last_of)
    # Make sure of day precision or things will be unusably slow!
    assert expr.include?(@pdate_20071030), "#{expr.to_s} should include #{@pdate_20071030.to_s}"
    assert !expr.include?(@pdate_20071008), "#{expr.to_s} should not include #{@pdate_20071008.to_s}"
  end
  
  def test_second_to_last_week_in_month
    expr = WIMonth.new(Second_to_last)
    # Make sure of day precision or things will be unusably slow!
    assert expr.include?(@pdate_20071024), "#{expr.to_s} should include #{@pdate_20071024}"
    assert !expr.include?(@pdate_20071008), "#{expr.to_s} should not include #{@pdate_20071008}"
  end

  def test_dates_mixin_second_week_in_month
    dates = WIMonth.new(Second).dates(@date_range)
    assert dates.size == 14, "Expected 14 dates, was #{dates.size}"
    assert dates.first.mday == 8, "Expected first date.mday to be 8, was #{dates.first.mday}" 
    assert dates.last.mday == 14, "Expected last date.mday to be 14, was #{dates.last.mday}"
  end

  def test_dates_mixin_last_week_in_month
    dates = WIMonth.new(Last).dates(@date_range)
    assert dates.size == 14, "Expected 14 dates, was #{dates.size}"
    assert dates.first.mday == 25, "Expected first date.mday to be 25, was #{dates.first.mday}"
    assert dates.last.mday == 28, "Expected last date.mday to be 28, was #{dates.last.mday}" 
  end

  def test_week_in_month_to_s
    assert_equal 'last week of any month', WIMonth.new(Last).to_s
  end

end
