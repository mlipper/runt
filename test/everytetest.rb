#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for EveryTE class
# Author:: Matthew Lipper

class EveryTETest < BaseExpressionTest

  def test_every_other_week
    date = @pdate_20081112
    expr = EveryTE.new(date, 14, DPrecision::DAY)
    assert !expr.include?(date + 7)
    assert expr.include?(date + 14)
  end

  def test_every_2_minutes
    date = @pdate_200401282100
    expr=EveryTE.new(date, 2)
    assert expr.include?(date + 2), "Expression #{expr.to_s} should include #{(date + 2).to_s}"
    assert expr.include?(date + 4), "Expression #{expr.to_s} should include #{(date + 4).to_s}"
    assert !expr.include?(date - 2), "Expression #{expr.to_s} should not include #{(date - 2).to_s}"
  end

  def test_every_3_days
    # Match every 3 days begining 2007-11-14
    date = @pdate_20071114
    expr=EveryTE.new(date, 3)
    assert expr.include?(date + 6), "Expression #{expr.to_s} should include #{(date + 6).to_s}"
    assert expr.include?(date + 9), "Expression #{expr.to_s} should include #{(date + 9).to_s}"
    assert !expr.include?(date + 1), "Expression #{expr.to_s} should not include #{(date + 1).to_s}"
    assert !expr.include?(date - 3), "Expression #{expr.to_s} should not include #{(date - 3).to_s}"
  end


  def test_to_s
    date=@pdate_20071116100030
    every_thirty_seconds=EveryTE.new(date, 30)
    assert_equal "every 30 seconds starting #{Runt.format_date(date)}", every_thirty_seconds.to_s
  end

end
