#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt/dateprecision'
require 'runt/temporalexpression'
require 'date'

=begin
  Author: Matthew Lipper
=end

class TemporalExpressionTest < Test::Unit::TestCase

	include Runt
	include DatePrecision

	def test_collection_te
    
		#base class that should always return false
		expr = CollectionTE.new
  
		assert(!expr.includes(Date.today))	
	
	end
  
	def test_union_te
    
		dt = Date.civil(2003,12,30)
		#dt = DatePrecision.second(2003,12,30)
		
		expr1 = ArbitraryTE.new(dt)
  	
		assert(expr1.includes?(dt))	
	
		dt2 = Date.civil(2003,12,31)

		assert(!expr1.includes?(dt2))

		expr2 = ArbitraryTE.new(dt2)
  	
		assert(expr2.includes?(dt2))
		
		union_expr = UnionTE.new
		
		union_expr.add(dt).add(dt2)
		
		assert(union_expr.includes?(dt))
		
		assert(union_expr.includes?(dt2))
	
	end
	
	def test_day_in_month_te

		#Friday, January 16th 2004
		dt1 = Date.civil(2004,1,16)

		#Friday, January 9th 2004
		dt2 = Date.civil(2004,1,9)

		#third Friday of the month
		expr1 = DayInMonthTE.new(Third,Friday)

		#second Friday of the month
		expr2 = DayInMonthTE.new(Second,Friday)

		assert(expr1.includes?(dt1))
		
		assert(!expr1.includes?(dt2))	
			
		assert(expr2.includes?(dt2))	

		assert(!expr2.includes?(dt1))	

		#Sunday, January 25th 2004
		dt3 = Date.civil(2004,1,25)
		
		#last Sunday of the month
		expr3 = DayInMonthTE.new(Last_of,Sunday)
		expr3.print(dt3)
		assert(expr3.includes?(dt3))	

end

def test_range_each_year_te
end

end