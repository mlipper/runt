#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for DIMonth class
# Author:: Matthew Lipper

class DIMonthTest < BaseExpressionTest
  def setup
    super
    @date_range = @date_20050101..@date_20051231
  end

  ###
  # Dates functionality & tests contributed by Emmett Shear
  ###
  def test_dates_mixin_first_tuesday
    dates = DIMonth.new(First, Tuesday).dates(@date_range)
    assert dates.size == 12
    dates.each do |d|
      assert @date_range.include?(d)
      assert d.wday == 2 # tuesday
      assert d.day < 8 # in the first week
    end
  end

  def test_dates_mixin_last_friday
    dates = DIMonth.new(Last, Friday).dates(@date_range)
    assert dates.size == 12
    month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] 
    dates.each do |d|
      assert @date_range.include?(d)
      assert d.wday == 5 # friday
      assert d.day > month_days[d.month-1] - 8 # last week
    end
  end

  def test_third_friday_of_the_month
    expr = DIMonth.new(Third,Friday)
    assert expr.include?(@date_20040116), "Third Friday of the month should include #{@date_20040116.to_s}"
    assert !expr.include?(@date_20040109), "Third Friday of the month should not include #{@date_20040109.to_s}"
  end

  def test_second_friday_of_the_month
    expr = DIMonth.new(Second,Friday)
    assert expr.include?(@date_20040109), "Second Friday of the month should include #{@date_20040109.to_s}"
    assert !expr.include?(@date_20040116), "Second Friday of the month should not include #{@date_20040116.to_s}"
  end
  
  def test_last_sunday_of_the_month
    expr = DIMonth.new(Last_of,Sunday)
    assert expr.include?(@date_20040125), "Last Sunday of the month should include #{@date_20040125}"
  end
  
  def test_to_s
    assert_equal 'last Sunday of the month', DIMonth.new(Last_of,Sunday).to_s
  end

end
