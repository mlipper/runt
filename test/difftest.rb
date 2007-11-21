#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for Diff class
# Author:: Matthew Lipper

class DiffTest < BaseExpressionTest

  def setup
    super
    @diff = Diff.new(@stub1, @stub2)
    @date = @pdate_20071008
  end

  def test_initialize
    assert_same @stub1, @diff.expr1, "Expected #{@stub1} instance used to create expression. Instead got #{@diff.expr1}"
    assert_same @stub2, @diff.expr2, "Expected #{@stub2} instance used to create expression. Instead got #{@diff.expr2}"
  end

  def test_to_s
    assert_equal @stub1.to_s + ' except for ' + @stub2.to_s, @diff.to_s
  end

  def test_include
    # Diff will match only if expr1 && !expr2
    @stub1.match = false
    @stub2.match = false
    assert !@diff.include?(@date), "Diff instance should not include any dates"
    @stub2.match = true
    assert !@diff.include?(@date), "Diff instance should not include any dates"
    @stub1.match = true
    assert !@diff.include?(@date), "Diff instance should not include any dates"
    @stub2.match = false
    assert @diff.include?(@date), "Diff instance should include any dates"
  end
end
