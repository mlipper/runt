#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for YearTE class
# Author:: Matthew Lipper

class YearTETest < BaseExpressionTest

  def test_2006
    expr = YearTE.new(2006)
    assert expr.include?(@pdate_20060914), "Expression #{expr.to_s} should include #{@pdate_20060914}"
    assert !expr.include?(@pdate_20071008), "Expression #{expr.to_s} should include #{@pdate_20071008}"
    assert expr.include?(@date_20060504), "Expression #{expr.to_s} should include #{@date_20060504}"
    assert !expr.include?(@date_20051231), "Expression #{expr.to_s} should include #{@date_20051231}"
  end

  def test_to_s
    assert_equal 'during the year 1934', YearTE.new(1934).to_s
  end
  
end
