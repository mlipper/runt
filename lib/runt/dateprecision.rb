#!/usr/bin/env ruby

require 'runt'
require 'date'

=begin
  Date precision.  
  NOTE: This implementation maintains non-thread safe instance pool (at least until I learn Ruby)
  
  Author: Matthew Lipper
=end

module Runt
	
	module DatePrecision
				
		def DatePrecision.to_p(date,prec=DEFAULT)
				case prec
					when MINUTE then TimePoint.minute(*DatePrecision.explode(date,prec))
					when DAY_OF_MONTH then TimePoint.day_of_month(*DatePrecision.explode(date,prec))
					when HOUR_OF_DAY then TimePoint.hour_of_day(*DatePrecision.explode(date,prec))
					when MONTH then TimePoint.month(*DatePrecision.explode(date,prec))
					when YEAR then TimePoint.year(*DatePrecision.explode(date,prec))
					when SECOND then TimePoint.second(*DatePrecision.explode(date,prec))
					when MILLISECOND then raise "Not implemented."
					#~ else raise "Unknown precision #{prec}"						
					else TimePoint.default(*DatePrecision.explode(date,prec))						
				end
		end
		
		def DatePrecision.explode(date,prec)
			result = [date.year,date.month,date.day]
			if( prec > DAY_OF_MONTH )			
				result << date.hour << date.min << date.sec					
			end
			result
		end
		
		#Simple value class for keeping track of precisioned dates
		class Precision
			include Comparable

			attr_reader :precision
			private_class_method :new
			
			#Some constants w/arbitrary integer values used internally for comparisions
			YEAR_PREC = 0
			MONTH_PREC = 1
			DAY_OF_MONTH_PREC = 2
			HOUR_OF_DAY_PREC = 3
			MINUTE_PREC = 4
			SECOND_PREC = 5  
			MILLISECOND_PREC = 6
			
			#String values for display
			LABEL = { YEAR_PREC => "YEAR",
				MONTH_PREC => "MONTH",                   
				DAY_OF_MONTH_PREC => "DAY_OF_MONTH",
				HOUR_OF_DAY_PREC => "HOUR_OF_DAY",
				MINUTE_PREC => "MINUTE",
				SECOND_PREC => "SECOND",
				MILLISECOND_PREC => "MILLISECOND"}

			#Minimun values that precisioned fields get set to
			FIELD_MIN = { YEAR_PREC => 1,
			MONTH_PREC => 1,                   
			DAY_OF_MONTH_PREC => 1,
			HOUR_OF_DAY_PREC => 0,
			MINUTE_PREC => 0,
			SECOND_PREC => 0,
			MILLISECOND_PREC => 0}
			
			def Precision.year	
				new(YEAR_PREC) 
			end
			
			def Precision.month	
				new(MONTH_PREC) 
			end
			
			def Precision.day_of_month	
				new(DAY_OF_MONTH_PREC) 
			end
			
			def Precision.hour_of_day	
				new(HOUR_OF_DAY_PREC) 
			end
			
			def Precision.minute
				new(MINUTE_PREC) 
			end
			
			def Precision.second 
				new(SECOND_PREC) 
			end
			
			def Precision.millisecond	
				new(MILLISECOND_PREC) 
			end			
			
			def min_value() 
				FIELD_MIN[@precision] 
			end
			
			def initialize(prec)	
				@precision = prec 
			end
			
			def <=>(other)	
				self.precision <=> other.precision 
			end
			
			def ===(other)	
				self.precision == other.precision
			end
			
			def to_s
				"DatePrecision::#{LABEL[@precision]}"
			end
	end
	
 	#Pseudo Singletons:
	YEAR = Precision.year 
	MONTH = Precision.month                  
	DAY_OF_MONTH = Precision.day_of_month
	HOUR_OF_DAY = Precision.hour_of_day
	MINUTE = Precision.minute
	SECOND = Precision.second
	MILLISECOND = Precision.millisecond
	#Defaults to minute
	DEFAULT=MINUTE
	
	end
	
end