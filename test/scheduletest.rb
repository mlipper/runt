#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for Schedule classes
# Author:: Matthew Lipper
class ScheduleTest < Test::Unit::TestCase

  include Runt

  def test_create_new
    schedule = Schedule.new
    assert(!schedule.nil?,"Call to Schedule.new returned NULL reference")
  end
end