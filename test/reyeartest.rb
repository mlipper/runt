#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for REYear class
# Author:: Matthew Lipper

class REYearTest < BaseExpressionTest

  def test_ctor_one_arg
    expr = REYear.new(11)
    assert expr.start_month == 11, "Start month should equal 11"
    assert expr.end_month == 11, "End month should equal 11"
    assert expr.start_day == REYear::NO_DAY, "Start day should equal constant NO_DAY"
    assert expr.end_day == REYear::NO_DAY, "End day should equal constant NO_DAY"
  end
  
  def test_ctor_two_args
    expr = REYear.new(11,12)
    assert expr.start_month == 11, "Start month should equal 11"
    assert expr.end_month == 12, "End month should equal 12"
    assert expr.start_day == REYear::NO_DAY, "Start day should equal constant NO_DAY"
    assert expr.end_day == REYear::NO_DAY, "End day should equal constant NO_DAY"
  end

  def test_ctor_three_args
    expr = REYear.new(10,21,12)
    assert expr.start_month == 10, "Start month should equal 10"
    assert expr.end_month == 12, "End month should equal 12"
    assert expr.start_day == 21, "Start day should equal 21"
    assert expr.end_day == REYear::NO_DAY, "End day should equal constant NO_DAY"
  end

  def test_ctor_three_args
    expr = REYear.new(10,21,12,3)
    assert expr.start_month == 10, "Start month should equal 10"
    assert expr.end_month == 12, "End month should equal 12"
    assert expr.start_day == 21, "Start day should equal 21"
    assert expr.end_day == 3, "End day should equal 3"
  end

  def test_specific_days_same_month
    expr = REYear.new(10,20,10,29)
    assert expr.include?(@pdate_20071028), "#{expr.to_s} should include #{@pdate_20071028}" 
    assert !expr.include?(@pdate_20071114), "#{expr.to_s} should not include #{@pdate_20071114}" 
    assert !expr.include?(@pdate_20071030), "#{expr.to_s} should not include #{@pdate_20071030}" 
    assert !expr.include?(@pdate_20071008), "#{expr.to_s} should not include #{@pdate_20071008}" 
  end

  def test_specific_days_different_months
    expr = REYear.new(5,31,9,6)
    assert expr.include?(@pdate_198606), "#{expr.to_s} should include #{@pdate_198606}" 
    assert expr.include?(@date_20040806), "#{expr.to_s} should include #{@date_20040806}" 
    assert !expr.include?(@pdate_20071008), "#{expr.to_s} should not include #{@pdate_20071008}"  
  end

  def test_default_days_different_months
    expr = REYear.new(11,12)
    assert expr.include?(@date_19611101), "#{expr.to_s} should include #{@date_19611101}"
    assert !expr.include?(@pdate_198606), "#{expr.to_s} should not include #{@pdate_198606}" 
  end

  def test_all_defaults
    expr = REYear.new(8)
    assert expr.include?(@date_20040806), "#{expr.to_s} should include #{@date_20040806}" 
    assert !expr.include?(@pdate_198606), "#{expr.to_s} should not include #{@pdate_198606}" 
    assert !expr.include?(@date_19611101), "#{expr.to_s} should not include #{@date_19611101}"
  end
  
  def test_same_days_same_month
    # Bug #5741
    expr = REYear.new(9,21,9,21)
    assert expr.include?(@pdate_20060921), "#{expr.to_s} should include #{@pdate_20060921.to_s}" 
    assert !expr.include?(@pdate_20060914), "#{expr.to_s} should not include #{@pdate_20060914.to_s}"
  end

  def test_to_s
    assert_equal 'June 1st through July 2nd', REYear.new(6, 1, 7, 2).to_s
  end
  
end
