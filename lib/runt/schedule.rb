#!/usr/bin/env ruby


=begin
  Schedule.
  
  Author: Matthew Lipper
=end

module Runt
	
		
	class Schedule
		
	
		def initialize
			@elements = Hash.new
		end
		
		def dates(event, date_range)
		
		end
		
		def is_occurring?(event, date)
			
			return false unless @elements[event].nil? == false
			
			elements.each{|i| i.is_occurring?(event,date)}
		end
		
	end
	
	class ScheduleElement
		
		def initialize(expr)
			@expression = expr
		end
		
		def is_occurring?(event, date)
			@expression.includes?(date)
		end
		
	end


end