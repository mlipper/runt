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
 def test_add
  schedule = Schedule.new
	elmo_party = Event.new("Elmo's Birthday Party",schedule)
  schedule.add(elmo_party,RangeEachDayTE.new(10,00,16,00))
	assert(schedule.is_occurring?(elmo_party, TimePoint.new(2004,2,1,11,06)))	 
	assert(schedule.is_occurring?(!elmo_party, TimePoint.new(2004,2,1,9,06)))
	assert(elmo_party.schedule==schedule)	 
 end
 
end
