#!/usr/bin/env ruby

require 'runt'
require 'date'

=begin
  Date precision.  
  NOTE: This implementation maintains non-thread safe instance pool (at least until I learn Ruby)
  
  Author: Matthew Lipper
=end

class Date
	
	include Runt

	attr_accessor :date_precision
  
	class << self

  	alias_method :old_civil, :civil

		def civil(*args)		
			if(args[0].instance_of?(Runt::DatePrecision::Precision))
				precision = args.shift
			else
				return Runt::DatePrecision.day_of_month(*args)
				#precision = nil
			end
			_civil = old_civil(*args)
			_civil.date_precision = precision
			_civil
		end
	end

	def + (n)
		raise TypeError, 'expected numeric' unless n.kind_of?(Numeric) 
		
		if(leap?) 
			days_in_year = 365
		else
			days_in_year = 366
		end
		
		case @date_precision
			when Runt::DatePrecision::YEAR then 
				return new_self_plus(n){ |n| n = n*days_in_year }	
			when Runt::DatePrecision::MONTH then 
				return new_self_plus(n){ |n| n = (n*(days_in_year/12).to_i)} 
			#Default behaviour already in Date
			when Runt::DatePrecision::DAY_OF_MONTH then 
				return new_self_plus(n){ |n| n = n }			
		end
		#~ return self.class.new0(@ajd + n, @of, @sg)
	end
	
	private

	def new_self_plus(n)		
		if(block_given?)
			n=yield(n) 
			#~ puts "n==#{n}"
		end
		
		return Runt::DatePrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
	end
end

class DateTime

	attr_accessor :date_precision
  
	class << self

  	alias_method :old_civil, :civil

		def civil(*args)
			if(args[0].instance_of?(Runt::DatePrecision::Precision))
				precision = args.shift
			else
				return Runt::DatePrecision.minute(*args)			
				#precision = nil
			end
		_civil = old_civil(*args)
		_civil.date_precision = precision
		_civil
		end
	end
		
	
	def + (n)
		raise TypeError, 'expected numeric' unless n.kind_of?(Numeric) 
		case @date_precision
			when Runt::DatePrecision::HOUR_OF_DAY then n = (n*(1.to_r/24) )			
			when Runt::DatePrecision::MINUTE then n = (n*(1.to_r/1440) )		
			when Runt::DatePrecision::SECOND then n = (n*(1.to_r/86400) )
		end
		return self.class.new0(@ajd + n, @of, @sg)
	end

end

module Runt
	
	module DatePrecision
  
		def DatePrecision.year(yr,*ignored)
			Date::civil( YEAR, yr, MONTH.min_value, DAY_OF_MONTH.min_value  )
		end

		def DatePrecision.month( yr,mon,*ignored )    
			Date::civil( MONTH, yr, mon, DAY_OF_MONTH.min_value  )
		end

		def DatePrecision.day_of_month( yr,mon,day,*ignored )
			Date::civil( DAY_OF_MONTH, yr, mon, day )			
		end
      
		def DatePrecision.hour_of_day( yr,mon,day,hr=HOUR_OF_DAY.min_value,*ignored ) 
			DateTime::civil( HOUR_OF_DAY, yr, mon, day,hr,MINUTE.min_value, SECOND.min_value)						
		end
  
		def DatePrecision.minute( yr,mon,day,hr=HOUR_OF_DAY.min_value,min=MINUTE.min_value,*ignored )  
			DateTime::civil( MINUTE, yr, mon, day,hr,min, SECOND.min_value)									
		end
  
		def DatePrecision.second( yr,mon,day,hr=HOUR_OF_DAY.min_value,min=MINUTE.min_value,sec=SECOND.min_value,*ignored ) 
			DateTime::civil( SECOND, yr, mon, day,hr,min, sec)									
		end
  
		def DatePrecision.millisecond( yr,mon,day,hr,min,sec,ms,*ignored )
			raise "Not implemented yet."
		end

		def DatePrecision.default(*args)  
			DateTime::civil(DEFAULT, *args)									
		end

		def DatePrecision.to_p(date,prec=DEFAULT)
				puts prec
				case prec
					when MINUTE then DatePrecision.minute(*DatePrecision.explode(date))
					when DAY_OF_MONTH then DatePrecision.day_of_month(*DatePrecision.explode(date))
					when HOUR_OF_DAY then DatePrecision.hour_of_day(*DatePrecision.explode(date))
					when MONTH then DatePrecision.month(*DatePrecision.explode(date))
					when YEAR then DatePrecision.year(*DatePrecision.explode(date))
					when SECOND then DatePrecision.second(*DatePrecision.explode(date))
					when MILLISECOND then raise "Not implemented."
					#~ else raise "Unknown precision #{prec}"						
					else DatePrecision.default(*DatePrecision.explode(date))						
				end
		end
		
		def DatePrecision.explode(date)
			result = [date.year,date.month,date.day]
			if( date.instance_of? DateTime )			
				result << date.hour << date.min << date.sec					
			end
			p result 
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
	
	class DatePrec < Date
  
		include DatePrecision

		def initialize(*args)
			civil(*args)
		end
	
	end
	
	class DateTimePrec < DateTime
  
		include DatePrecision

		def initialize(*args)
			civil(*args)
		end
	
	end
	
end