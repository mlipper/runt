#!/usr/bin/env ruby

module Runt
	
		
  # Implementation of a <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
  # for recurring calendar events created by Martin Fowler.
	class Schedule
			
		def initialize
			@elements = Array.new
		end
		
		#For the given date range, returns an Array of TimePoint objects at which 
		#the supplied event is scheduled to occur. 
		def dates(event, date_range)
		
		end
		
		def is_occurring?(event, date)
			elements.each { | element | element.is_occurring?(event, date) }
		end
		
	end
	
	
	private
	class ScheduleElement
		
		def initialize(event, expression)
			@event = event
			@expression = expression
		end
		
		def is_occurring?(event, date)			
			return false unless @event == event
			@expression.includes?(date)			
		end
		
	end


end