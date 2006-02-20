#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'pp'

class RuntModuleTest < Test::Unit::TestCase
  
  def test_context_init
    assert(!Runt.context.nil?)
    assert(Runt.context==Runt.context)
    Runt::DIWeek.new(1).push
    assert(Runt.context==Runt.context)
  end

end
