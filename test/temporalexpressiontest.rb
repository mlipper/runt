#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for TExpr classes
# Author:: Matthew Lipper

class TExprTest < BaseExpressionTest

  include TExpr

  def test_include
    assert !self.include?(true), "Default include? method should always return false"
  end

  def test_to_s
    assert_equal self.to_s, 'TExpr', "Default to_s method should always return 'TExpr'"
  end

  def test_or_from_union
    union = Union.new
    same_union = union.or(@stub1)
    assert_same union, same_union, "Expected same Union instance that received the or method"
    assert_same @stub1, union.expressions.first, "Union instance should have added the stub expression"
  end

  def test_or_from_nonunion
    result = @stub1.or(@stub2) {|e| e}
    assert_equal Runt::Union, result.class, "Expected an Union instance. Instead got #{result.class}"
    assert_same @stub1, result.expressions.first, "Result should be new Union instance containing both stub expressions"
    assert_same @stub2, result.expressions.last, "Result should be new Union instance containing both stub expressions"
  end

  def test_and_from_intersect
    intersect = Intersect.new
    result = intersect.and(@stub1)
    assert_same intersect, result, "Expected same Intersect instance that received the and method"
    assert_same @stub1, intersect.expressions.first, "Intersect instance should have added the stub expression"
  end

  def test_or_from_nonintersect
    result = @stub1.and(@stub2) {|e| e}
    assert_equal Runt::Intersect, result.class, "Expected an Intersect instance. Instead got #{result.class}"
    assert_same @stub1, result.expressions.first, "Result should be new Intersect instance containing both stub expressions"
    assert_same @stub2, result.expressions.last, "Result should be new Intersect instance containing both stub expressions"
  end

  def test_minus
    result = @stub1.minus(@stub2) {|e| e}
    assert_equal Runt::Diff, result.class, "Expected an Diff instance. Instead got #{result.class}"
    assert_same @stub1, result.expr1, "Expected first stub instance used to create Diff expression"
    assert_same @stub2, result.expr2, "Expected second stub instance used to create Diff expression"
  end

  def test_dates_no_limit
    # Normally, your range is made up of Date-like Objects
    range = 1..3
    assert @stub1.dates(range).empty?, "Expected empty Array of Objects returned from stub expression"
    @stub1.match = true
    result = @stub1.dates(range)
    assert_equal 1, result[0], "Expected Array of Objects given by range to be returned from stub expression"
    assert_equal 2, result[1], "Expected Array of Objects given by range to be returned from stub expression"
    assert_equal 3, result[2], "Expected Array of Objects given by range to be returned from stub expression"
  end

  def test_dates_with_limit
    range = 1..3
    assert @stub1.dates(range).empty?, "Expected empty Array of Objects returned from stub expression"
    @stub1.match = true
    result = @stub1.dates(range,2)
    assert_equal 2, result.size, "Expected Array of only 2 Objects. Got #{result.size}"
    assert_equal 1, result[0], "Expected Array of Objects given by range to be returned from stub expression"
    assert_equal 2, result[1], "Expected Array of Objects given by range to be returned from stub expression"
  end

end
