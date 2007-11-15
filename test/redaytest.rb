#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for REDay class
# Author:: Matthew Lipper

class REDayTest < BaseExpressionTest


  def test_noon_to_430
    #noon to 4:30pm
    expr = REDay.new(12,0,16,30)
    assert expr.include?(@pdate_201205081515), "Expression #{expr.to_s} should include #{@pdate_201205081515.to_s}"
    assert expr.include?(@pdate_192204181630), "Expression #{expr.to_s} should include #{@pdate_192204181630.to_s}"
    assert expr.include?(@pdate_197506051200), "Expression #{expr.to_s} should include #{@pdate_197506051200.to_s}"
    assert !expr.include?(@pdate_201205080315), "Expression #{expr.to_s} should not include #{@pdate_201205080315.to_s}"
  end
  def test_830_to_midnight
    expr = REDay.new(20,30,00,00)
    assert expr.include?(@pdate_200401282100), "Expression #{expr.to_s} should include #{@pdate_200401282100.to_s}"
    assert expr.include?(@pdate_200401280000), "Expression #{expr.to_s} should include #{@pdate_200401280000.to_s}"
    assert !expr.include?(@pdate_200401280001), "Expression #{expr.to_s} should not include #{@pdate_200401280001.to_s}"
  end

  def test_range_each_day_te_to_s
    assert_equal 'from 11:10PM to 01:20AM daily', REDay.new(23,10,1,20).to_s
  end
  
end
