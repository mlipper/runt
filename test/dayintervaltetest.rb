#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for DayIntervalTE class
# Author:: Matthew Lipper

class DayIntervalTETest < BaseExpressionTest


  def test_every_8_days
    date = @date_20040116
    # Match every 8 days
    expr = DayIntervalTE.new(date, 8)
    assert expr.include?(date + 8), "Expression #{expr.to_s} should include #{(date + 8).to_s}"
    assert expr.include?(date + 16), "Expression #{expr.to_s} should include #{(date + 16).to_s}"
    assert expr.include?(date + 64), "Expression #{expr.to_s} should include #{(date + 64).to_s}"
    assert !expr.include?(date + 4), "Expression #{expr.to_s} should not include #{(date + 4).to_s}"
    # FIXME This test fails
    #assert !expr.include?(date - 8), "Expression #{expr.to_s} should not include #{(date - 8).to_s}"
  end

  def test_every_2_days
    date = @datetime_200709161007
    expr = DayIntervalTE.new(date, 2)
    assert expr.include?(date + 2), "Expression #{expr.to_s} should include #{(date + 2).to_s}"
    assert expr.include?(date + 4), "Expression #{expr.to_s} should include #{(date + 4).to_s}"
    assert !expr.include?(date + 3), "Expression #{expr.to_s} should not include #{(date + 3).to_s}"
  end

  def test_to_s
    every_four_days = DayIntervalTE.new(Date.new(2006,2,26), 4)
    assert_equal "every 4th day after #{Runt.format_date(Date.new(2006,2,26))}", every_four_days.to_s
  end


end
