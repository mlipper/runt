#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for REWeek class
# Author:: Matthew Lipper

class REWeekTest < BaseExpressionTest


  def test_invalid_ctor_arg
    assert_raises(ArgumentError,"Expected ArgumentError for invalid day of week ordinal"){ REWeek.new(10,4) }
  end

  def test_monday_thru_friday
    expr = REWeek.new(Mon,Fri)
    assert expr.include?(@date_20040116), "Expression #{expr.to_s} should include #{@date_20040116.to_s}"
    assert !expr.include?(@date_20040125), "Expression #{expr.to_s} should not include #{@date_20040125.to_s}"
  end
  
  def test_friday_thru_tuesday
    expr = REWeek.new(Fri,Tue)
    assert expr.include?(@date_20040125), "Expression #{expr.to_s} should include #{@date_20040125.to_s}"
    assert !expr.include?(@pdate_20071024), "Expression #{expr.to_s} should not include #{@pdate_20071024.to_s}"
  end
  
  def test_range_each_week_te
    #Friday through Tuesday
     expr = REWeek.new(Friday,Tuesday) 
     assert expr.include?(@time_20070928000000), "#{expr.inspect} should include Fri 12am"
     assert expr.include?(@time_20070925115959), "#{expr.inspect} should include Tue 11:59pm"
     assert !expr.include?(@time_20070926000000),"#{expr.inspect} should not include Wed 12am"
     assert !expr.include?(@time_20070927065959),"#{expr.inspect} should not include Thurs 6:59am"
     assert !expr.include?(@time_20070927115900),"#{expr.inspect} should not include Thurs 1159am"
     assert expr.include?(@time_20070929110000), "#{expr.inspect} should include Sat 11am"
     assert expr.include?(@time_20070929000000), "#{expr.inspect} should include Sat midnight"
     assert expr.include?(@time_20070929235959), "#{expr.inspect} should include Saturday one minute before midnight"
     assert expr.include?(@time_20070930235959), "#{expr.inspect} should include Sunday one minute before midnight"
  end
  
  def test_to_s
    assert_equal 'all week', REWeek.new(Tuesday,Tuesday).to_s
    assert_equal 'Thursday through Saturday', REWeek.new(Thursday,Saturday).to_s
  end

  def test_dates_mixin
    dates = REWeek.new(Tue,Wed).dates(@pdate_20071008..@pdate_20071030)
    assert dates.size == 7
  end
  
end
