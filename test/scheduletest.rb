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
    elmo_party_schedule = Schedule.new
    elmo_party = Event.new("Elmo's Birthday Party",elmo_party_schedule)
    elmo_party_schedule.add(elmo_party,@elmo_party_te)
    assert(elmo_party_schedule.is_occurring?(elmo_party, TimePoint.new(2004,2,1,11,06)))
    assert(elmo_party_schedule.is_occurring?(!elmo_party, TimePoint.new(2004,2,1,9,06)))
    assert(elmo_party.schedule==elmo_party_schedule)

    tv_schedule = Schedule.new
    elmos_world = Event.new("Elmo's World",tv_schedule)

    p @sesame_street_broadcast_te
    #schedule.add(

  end

  def setup
    #~ @elmo_party = Event.new("Elmo's Birthday Party")
    @elmo_party_te = RangeEachDayTE.new(10,00,16,00)
    @sesame_street_broadcast_te = IntersectionTE.new.add(RangeEachWeekTE.new(Monday,Friday)).add(RangeEachDayTE.new(9,00,10,00))
  end
end
