#!/usr/bin/env ruby

#Schedule.
#  
#  Author: Matthew Lipper

module Runt
	
		
	class Schedule
		
	
		def initialize
			@elements = Array.new
		end
		
		def dates(event, date_range)
		
		end
		
		def is_occurring?(event, date)
			elements.each { | element | element.is_occurring?(event, date) }
		end
		
	end
	
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