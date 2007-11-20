#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for Union class
# Author:: Matthew Lipper

class UnionTest < BaseExpressionTest

  def setup
    super
    @union = Union.new
    @stub1 = StubExpression.new(false, "stub 1", false)
    @stub2 = StubExpression.new(false, "stub 2", false)
    @date = @pdate_20071028
  end

  def test_include
    assert !@union.include?(@date), "Empty Union instance should not include any dates"
    @union.add(@stub1).add(@stub2) # both expressions will return false
    assert !@union.include?(@date), "Union instance should not include any dates"
    @stub2.match = true
    assert @union.include?(@date), "Union instance should include any dates"
    @stub2.match = false
    @stub1.match = true
    assert @union.include?(@date), "Union instance should include any dates"

  end
  
  def test_to_s
    assert_equal 'empty', @union.to_s
    @union.add(@stub1)
    assert_equal 'every ' + @stub1.to_s, @union.to_s
    @union.add(@stub2)
    assert_equal 'every ' + @stub1.to_s + ' or ' + @stub2.to_s, @union.to_s
  end
  
end
