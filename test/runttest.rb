#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'pp'

class RuntModuleTest < Test::Unit::TestCase
  
  def test_last
    assert Runt::Last == -1
  end
  
  def test_last_of
    assert Runt::Last_of == -1
  end

  def test_second_to_last
    assert Runt::Second_to_last == -2
  end

  def test_ordinals
    #1.upto(31){ |n| puts Runt.ordinalize(n); }
    assert_equal '1st', Runt.ordinalize(1)
    assert_equal '33rd', Runt.ordinalize(33)
    assert_equal '50th', Runt.ordinalize(50)
    assert_equal '2nd', Runt.ordinalize(2)
    assert_equal 'second to last', Runt.ordinalize(-2)
    assert_equal 'last', Runt.ordinalize(-1)
  end
  
end
