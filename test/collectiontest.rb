#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for Collection class
# Author:: Matthew Lipper

class CollectionTest < BaseExpressionTest

  def setup
    super
    @expr = Collection.new
  end

  def test_initialize
    assert !@expr.expressions.nil?, "Newly created Collection should have a non-nil @expressions attribute"
    assert @expr.expressions.empty?, "Newly created Collection should have an empty @expressions attribute"
  end

  def test_include
    #base class that should always return false
    assert !@expr.include?(StubExpression.new(true)), "Collection#include? should always return false"
  end


  def test_to_s
    assert_equal 'empty', @expr.to_s
    assert_equal 'empty', @expr.to_s{['b','oo']}
    dim = StubExpression.new(false,"Mock1")
    @expr.expressions << dim
    assert_equal 'ff' + dim.to_s, @expr.to_s{['ff','nn']}
    red = StubExpression.new(false, "Mock2")
    @expr.expressions << red
    assert_equal 'ff' + dim.to_s + 'nn' + red.to_s, @expr.to_s{['ff','nn']}
    wim = StubExpression.new(false, "Mock3")
    @expr.expressions << wim
    assert_equal 'ff' + dim.to_s + 'nn' + red.to_s + 'nn' + wim.to_s, @expr.to_s{['ff','nn']}
  end

  def test_add
    e1 = StubExpression.new
    e2 = StubExpression.new
    assert @expr.expressions.empty?, "Empty Collection should not include any expressions"
    result = @expr.add(e1)
    assert_same @expr, result, "Collection#add method should return self instance"
    assert @expr.expressions.include?(e1), "Collection should include added expression"
    @expr.add(e2)
    assert @expr.expressions.include?(e2), "Collection should include added expression"
    assert_same e2, @expr.expressions.pop, "Collection should keep added expressions in stack order"
    assert_same e1, @expr.expressions.pop, "Collection should keep added expressions in stack order"
  end

  def test_overlap
    stub = StubExpression.new(false, "stubby", true) # start with "always overlap?" stub
    assert !@expr.overlap?(stub), "Empty Collection should never overlap"
    @expr.add StubExpression.new
    assert @expr.overlap?(stub), "Collection should overlap with given stub argument"
    assert_same stub.args[0], @expr.expressions.first, "First expression should be given to stub in the first call to overlap?"
    stub.overlap = false
    assert !@expr.overlap?(stub), "Collection should not overlap with given stub argument"
  end

end
