#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for DIWeek class
# Author:: Matthew Lipper

class DIWeekTest < BaseExpressionTest

  def test_day_in_week_te
    expr = DIWeek.new(Friday)
    assert expr.include?(@date_20040109), "'Friday' should include #{@date_20040109} which is a Friday"
    assert expr.include?(@date_20040116), "'Friday' should include #{@date_20040116} which is a Friday"
    assert !expr.include?(@date_20040125), "'Friday' should not include #{@date_20040125} which is a Sunday"
  end

  def test_day_in_week_te_to_s
    assert_equal 'Friday', DIWeek.new(Friday).to_s
  end

  def test_day_in_week_dates
    expr = DIWeek.new(Sunday)
    dates = expr.dates(@date_20050101..@date_20050131)
    assert dates.size == 5, "There are five Sundays in January, 2005: found #{dates.size}"
    assert dates.include?(@date_20050102), "Should include #{@date_20050102}"
    assert dates.include?(@date_20050109), "Should include #{@date_20050109}"
    assert dates.include?(@date_20050116), "Should include #{@date_20050116}"
    assert dates.include?(@date_20050123), "Should include #{@date_20050123}"
    assert dates.include?(@date_20050130), "Should include #{@date_20050130}"
  end

end
