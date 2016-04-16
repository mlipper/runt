#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for Intersect class
# Author:: Matthew Lipper

class IntersectTest < BaseExpressionTest

  def setup
    super
    @intersect = Intersect.new
    @date = @pdate_20071008
  end

  def test_to_s
    assert_equal 'empty', @intersect.to_s
    @intersect.add(@stub1)
    assert_equal 'every ' + @stub1.to_s, @intersect.to_s
    @intersect.add(@stub2)
    assert_equal 'every ' + @stub1.to_s + ' and ' + @stub2.to_s, @intersect.to_s
  end


  def test_include
    assert !@intersect.include?(@date), "Empty Intersect instance should not include any dates"
    @intersect.add(@stub1).add(@stub2) # both expressions will return false
    assert !@intersect.include?(@date), "Intersect instance should not include any dates"
    @stub2.match = true
    assert !@intersect.include?(@date), "Intersect instance should not include any dates"
    @stub1.match = true
    assert @intersect.include?(@date), "Intersect instance should include any dates"
  end
end
