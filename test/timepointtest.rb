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
		date_time = TimePoint.new(2004,2,29,22,13,2)
		assert(!date_time.date_precision.nil?)		
	end
	
	def test_plus		
		year_prec = DatePrecision.year(2010,8)
		#Year precision will truncate month		
		assert(DatePrecision.year(2022,12)==(year_prec+12))		
		month_prec = DatePrecision.month(2004,8)
		assert(DatePrecision.month(2005,1)==(month_prec+6))		
		#11:59 (:04 - ignored) December 31st, 1999 
		prec = DatePrecision.minute(1999,12,31,23,59,4)
 	end
	
end