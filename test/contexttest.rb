#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'pp'

class ContextTest < Test::Unit::TestCase

  include Runt
  include DPrecision

  def test_pop
    ctx = Context.new
    assert_nil ctx.pop
    obj = "boo"
    ctx.push obj 
    assert_equal ctx.pop, obj 
  end
  def test_push
    ctx = Context.new
    assert_raises(ArgumentError) { ctx.push }
  end

end
