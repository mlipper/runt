#!/usr/bin/env ruby

require 'date'
require 'runt'

=begin
  TimePoint - based the pattern by Martin Fowler
	See: http://martinfowler.com/ap2/timePoint.html
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
			end
			_civil = old_civil(*args)
			_civil.date_precision = precision
			_civil
		end
	end
	
	class << self; alias_method :new, :civil end
end

class DateTime

	class << self

  	alias_method :old_civil, :civil

		def civil(*args)
			if(args[0].instance_of?(Runt::DatePrecision::Precision))
				precision = args.shift
			else
				return Runt::DatePrecision.second(*args)			
			end
		_civil = old_civil(*args)
		_civil.date_precision = precision
		_civil
		end
	end
		
	class << self; alias_method :new, :civil end	
end

module Runt
			
	class TimePoint < DateTime
		include DatePrecision

		attr_reader :date_precision
			
        def initialize(*args)
        	super(*args)
        end

        def + (n)
            raise TypeError, 'expected numeric' unless n.kind_of?(Numeric)
						
            if(leap?) 
                days_in_year = 365
            else
                days_in_year = 366
            end
						#FIXME!!!!
            case @date_precision
                when Runt::DatePrecision::YEAR then 
                    #~ return new_self_plus(n){ |n| n = n*days_in_year }	
										return Runt::DatePrecision::to_p(TimePoint::civil(year+n,month,day),@date_precision)
                when Runt::DatePrecision::MONTH then 
                    return new_self_plus(n){ |n| n = (n*(days_in_year/12).to_i)} 
                when Runt::DatePrecision::DAY_OF_MONTH then 
                    #Default behaviour already in Date
                    return new_self_plus(n){ |n| n = n }			
                when Runt::DatePrecision::HOUR_OF_DAY then 
                    return new_self_plus(n){ |n| n = (n*(1.to_r/24) ) }			
                when Runt::DatePrecision::MINUTE then 
                    return new_self_plus(n){ |n| n = (n*(1.to_r/1440) ) }		
                when Runt::DatePrecision::SECOND then 
                    return new_self_plus(n){ |n| n = (n*(1.to_r/86400) ) }
            end
        end
        
		def - (x)
			case x
				when Numeric; return self+(-x)
				#FIXME!!
				when Date;    return @ajd - x.ajd
			end
			raise TypeError, 'expected numeric or date'
		end
		
		def new_self_plus(n)		
			if(block_given?)
				n=yield(n) 
			end
			return Runt::DatePrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
		end
	end
end
