#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'runt/sugar'

class SugarTest < Test::Unit::TestCase
  include Runt

  def test_const_should_return_runt_constant
    assert_equal Runt::Monday, Runt.const('monday'), \
      "Expected #{Runt::Monday} but was #{Runt.const('monday')}"
  end
  
  def test_method_missing_should_define_dimonth
      ['first', 'second', 'third', 'fourth', \
	'last','second_to_last'].each do |ordinal|
        ['monday','tuesday','wednesday','thursday',\
	  'friday','saturday','sunday'].each do |day|
	  name = ordinal + '_' + day
	  result = self.send(name)
	  expected = DIMonth.new(Runt.const(ordinal), Runt.const(day))
	  assert_expression expected, result
	end
      end
  end
  
  def test_method_missing_should_define_diweek
    assert_expression(DIWeek.new(Monday), self.monday)
    assert_expression(DIWeek.new(Tuesday), self.tuesday)
    assert_expression(DIWeek.new(Wednesday), self.wednesday)
    assert_expression(DIWeek.new(Thursday), self.thursday)
    assert_expression(DIWeek.new(Friday), self.friday)
    assert_expression(DIWeek.new(Saturday), self.saturday)
    assert_expression(DIWeek.new(Sunday), self.sunday)
  end

  def test_parse_time
    assert_equal [13,2], parse_time('1','02','pm')
    assert_equal [1,2], parse_time('1','02','am')
  end

  def test_method_missing_should_build_re_day
    assert_expression(REDay.new(8,45,14,00), daily_8_45am_to_2_00pm)
  end

  private 
  def assert_expression(expected, actual)
    assert_equal expected.to_s, actual.to_s, \
      "Expected #{expected.to_s} but was #{actual.to_s}"
  end
end
