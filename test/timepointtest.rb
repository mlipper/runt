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

	def setup
		# 2010 (August - ignored)
		@year_prec = DatePrecision.year(2010,8)
		#August, 2004
		@month_prec = DatePrecision.month(2004,8)
		#January 25th, 2004 (11:39 am - ignored)
		@day_prec = DatePrecision.day_of_month(2004,1,25,11,39)
		#11:59(:04 - ignored), December 31st, 1999
		@minute_prec = DatePrecision.minute(1999,12,31,23,59,4)
		#12:00:10 am, March 1st, 2004
		@second_prec = DatePrecision.second(2004,3,1,0,0,10)
	end
	
	def test_new
		date = TimePoint.new(2004,2,29)
		assert(!date.date_precision.nil?)
		date_time = TimePoint.new(2004,2,29,22,13,2)
		assert(!date_time.date_precision.nil?)		
	end
	
	def test_plus		
		assert(DatePrecision.year(2022,12)==(@year_prec+12))		
		assert(DatePrecision.month(2005,1)==(@month_prec+6))		
		assert(DatePrecision.day_of_month(2004,2,1)==(@day_prec+7))				
		assert(DatePrecision.minute(2000,1,1,0,0)==(@minute_prec+1))				
		assert(DatePrecision.second(2004,2,29,23,59,59)==(@second_prec-11))				
 	end
	

	def test_minus		
		p DatePrecision.year(1998,12).ctime
		p @year_prec.ctime		
		temp = (@year_prec-12)
		assert(DatePrecision.year(1998,12)==(@year_prec-12))		
		
		#~ month_prec = DatePrecision.month(2004,8)
		#~ assert(DatePrecision.month(2005,1)==(month_prec+6))		

		#~ day_prec = DatePrecision.day_of_month(2004,1,25,11,39)
		#~ assert(DatePrecision.day_of_month(2004,2,1)==(day_prec+7))				
		
		#~ minute_prec = DatePrecision.minute(1999,12,31,23,59,4)
		#~ assert(DatePrecision.minute(2000,1,1,0,0)==(minute_prec+1))				
		
		#~ second_prec = DatePrecision.second(2004,3,1,0,0,10)
		#~ assert(DatePrecision.second(2004,2,29,23,59,59)==(second_prec-11))				
 	end



end