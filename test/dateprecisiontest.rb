#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt/dateprecision'
require 'date'

=begin
  Author: Matthew Lipper
=end
class DatePrecisionTest < Test::Unit::TestCase

	include Runt
	
	def test_comparable
		assert(DatePrecision::YEAR<DatePrecision::MONTH, "DatePrecision.year was not less than DatePrecision.month")	
		assert(DatePrecision::MONTH<DatePrecision::DAY_OF_MONTH, "DatePrecision.month was not less than DatePrecision.day_of_month")	
		assert(DatePrecision::DAY_OF_MONTH<DatePrecision::HOUR_OF_DAY, "DatePrecision.day_of_month was not less than DatePrecision.hour_of_day")	
		assert(DatePrecision::HOUR_OF_DAY<DatePrecision::MINUTE, "DatePrecision.hour_of_day was not less than DatePrecision.minute")	
		assert(DatePrecision::MINUTE<DatePrecision::SECOND, "DatePrecision.minute was not less than DatePrecision.second")	
		assert(DatePrecision::SECOND<DatePrecision::MILLISECOND, "DatePrecision.second was not less than DatePrecision.millisecond")	
	end
  
	def test_pseudo_singleton_instance
		assert(DatePrecision::YEAR.id==DatePrecision::YEAR.id, "Object Id's not equal.")	
		assert(DatePrecision::MONTH.id==DatePrecision::MONTH.id, "Object Id's not equal.")	
		assert(DatePrecision::DAY_OF_MONTH.id==DatePrecision::DAY_OF_MONTH.id, "Object Id's not equal.")	
		assert(DatePrecision::HOUR_OF_DAY.id==DatePrecision::HOUR_OF_DAY.id, "Object Id's not equal.")	
		assert(DatePrecision::MINUTE.id==DatePrecision::MINUTE.id, "Object Id's not equal.")	
		assert(DatePrecision::SECOND.id==DatePrecision::SECOND.id, "Object Id's not equal.")	
		assert(DatePrecision::MILLISECOND.id==DatePrecision::MILLISECOND.id, "Object Id's not equal.")	
	end

	def test_create_with_module_class_methods
		#December 12th, 1968
		no_prec = Date.civil(1968,12,12)
		#December 12th, 1968 (at 11:15 am - ignored)
		day_prec = DatePrecision.day_of_month(1968,12,12,11,15)
		assert(no_prec==day_prec, "Date instance does not equal precisioned instance.")	
		#December 2004 (24th - ignored)
		month_prec1 = DatePrecision.month(2004,12,24)
		#December 31st, 2004  (31st - ignored)
		month_prec2 = DatePrecision.month(2004,12,31)
		assert(month_prec1==month_prec2, "DatePrecision.month instances not equal.")	
		#December 2004
		month_prec3 = DatePrecision.month(2004,12)
		assert(month_prec1==month_prec3, "DatePrecision.month instances not equal.")	
		assert(month_prec2==month_prec3, "DatePrecision.month instances not equal.")	
		#December 2003
		month_prec4 = DatePrecision.month(2003,12)
		assert(month_prec4!=month_prec1, "DatePrecision.month instances not equal.")
	end	

	def test_to_precision
		
		#February 29th, 2004
		no_prec_date = Date.civil(2004,2,29)
		month_prec = DatePrecision.month(2004,2,29)
		assert(month_prec==DatePrecision.to_p(no_prec_date,DatePrecision::MONTH))

		#11:59:59 am, February 29th, 2004
		no_prec_datetime = DateTime.civil(2004,2,29,23,59,59)
		#~ puts no_prec_datetime.ctime
		assert(month_prec==DatePrecision.to_p(no_prec_datetime,DatePrecision::MONTH))

	end	
end