	#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'date'
require 'runt'

=begin
  Author: Matthew Lipper
=end
class TimePointTest < Test::Unit::TestCase

	include Runt
	
	def test_new		
		date = TimePoint.new(2004,2,29)
		assert(!date.date_precision.nil?)
		puts "#{date.ctime} : #{date.date_precision.to_s}"
		date_time = TimePoint.new(2004,2,29,22,13,2)
		assert(!date_time.date_precision.nil?)		
		puts "#{date_time.ctime} : #{date_time.date_precision.to_s}"
	end
end