#!/usr/bin/env ruby

require 'date'
require 'runt'

=begin
  TimePoint - based the pattern by Martin Fowler
	See: http://martinfowler.com/ap2/timePoint.html
  Author: Matthew Lipper
=end

module Runt
			
	class TimePoint < DateTime
		include DatePrecision

		attr_accessor :date_precision
			
		class << self
			alias_method :old_civil, :civil

			def civil(*args)
				if(args[0].instance_of?(DatePrecision::Precision))
					precision = args.shift
				else
					return DatePrecision.second(*args)			
				end
				_civil = old_civil(*args)
				_civil.date_precision = precision
				_civil
			end
		end
		
		class << self; alias_method :new, :civil end	

    	def + (n)
			raise TypeError, 'expected numeric' unless n.kind_of?(Numeric)
      		case @date_precision
				when DatePrecision::YEAR then 
					return DatePrecision::to_p(TimePoint::civil(year+n,month,day),@date_precision)
				when DatePrecision::MONTH then 
					current_date = self.class.to_date(self)
					return DatePrecision::to_p((current_date>>n),@date_precision)
				when DatePrecision::DAY_OF_MONTH then 
					return new_self_plus(n)
				when DatePrecision::HOUR_OF_DAY then 
					return new_self_plus(n){ |n| n = (n*(1.to_r/24) ) }			
				when DatePrecision::MINUTE then 
					return new_self_plus(n){ |n| n = (n*(1.to_r/1440) ) }		
        		when DatePrecision::SECOND then 
					return new_self_plus(n){ |n| n = (n*(1.to_r/86400) ) }
			end
		end
        
		def - (x)
				case x
					when Numeric then
						return self+(-x)
					#FIXME!!
					when Date;    return @ajd - x.ajd
				end
				raise TypeError, 'expected numeric or date'
		end
			
		def new_self_plus(n)		
			if(block_given?)
				n=yield(n) 
			end
			return DatePrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
		end
		
		def TimePoint.to_date(timepoint)
			if( timepoint.date_precision > DatePrecision::DAY_OF_MONTH) then				
				DateTime.new(timepoint.year,timepoint.month,timepoint.day,timepoint.hour,timepoint.min,timepoint.sec)
			end			
			return Date.new(timepoint.year,timepoint.month,timepoint.day)
		end
		
	end
		
end
