#!/usr/bin/env ruby

require 'date'
require 'runt/dateprecision'

=begin
  Author: Matthew Lipper
=end

module Runt

class TemporalExpression
	
	def includes(aDate)
		false
	end
  
	def log(expr, arg)
		#~ puts "#{to_s}:  #{expr}==#{arg}? #{expr == arg}."
	end
  
	def to_s
		"TemporalExpression"
	end

	protected :log

end

class CollectionTE < TemporalExpression

	attr_reader :expressions
	protected :expressions
  
	def initialize
		super
		@expressions = Array.new
	end
  
	def includes?(aDate)
		false
	end
  
	def add(anExpression)
		@expressions.push anExpression
		self
	end

	def to_s
		"CollectionTE"
	end
end

class UnionTE < CollectionTE

	def includes?(aDate)
		@expressions.each do |expr|
			log(expr,aDate)
			return true if expr == aDate 
		end
	end
 	def to_s
		"UnionTE"
	end
 
end

class IntersectionTE < CollectionTE

	def includes?(aDate)
		@expressions.each do |expr|
		log(expr,aDate)
		return false unless expr == aDate 
	end

	def to_s
		"IntersectionTE"
	end
	
end
  
end

class DifferenceTE < TemporalExpression

	def initialize(expr1, expr2)
		super
		@expr1 = expr1
		@expr2 = expr2	
	  end
  
	def includes?(aDate)
		log(expr,aDate)
		return false unless (@expr1.includes(aDate) && !expr2.includes(aDate))  
	end
	
	def to_s
		"DifferenceTE"
	end
  
end

class ArbitraryTE < TemporalExpression

	def initialize(aDate)
		super()
		@date_time = aDate
	end
	
	def includes?(aDate)
		log(@date_time,aDate)
		return true if @date_time == aDate
		false
	end
	
	def to_s
		"ArbitraryTE"
	end
end


class DayInMonthTE < TemporalExpression

	def initialize(offset, day_index)
		super()
		@day_index = day_index
		@offset = offset
	end
	
	def includes?(date)
		( day_matches?(date) ) && ( week_matches?(date) )
	end
	
	def day_matches?(date)
		@day_index == date.wday
	end
	
	def week_matches?(date)
		if(@offset > 0) 
			return week_from_start_matches?(date)
		else
			return week_from_end_matches?(date)
		end		
	end
	
	def week_from_start_matches?(date)
		week_in_month(date.day)==@offset
	end
	
	def week_from_end_matches?(date)
		n = days_left_in_month(date) + 1
		week_in_month(n) == @offset.abs
	end
	
	def week_in_month(day_in_month)
		((day_in_month - 1) / 7) + 1
	end
	
	def days_left_in_month(date)
		return max_day_of_month(date) - date.day
	end
	
	def max_day_of_month(date)
		result = 1
		date.step( Date.new(date.year,date.mon+1,1), 1 ){ |d| result=d.day unless d.day < result }		
		result
	end
	
	def to_s
		"DayInMonthTE"
	end
	
	def print(date)
		puts "DayInMonthTE: #{date}"
		puts "includes? == #{includes?(date)}"
		puts "day_matches? == #{day_matches?(date)}"
		puts "week_matches? == #{week_matches?(date)}"
		puts "week_from_start_matches? == #{week_from_start_matches?(date)}"
		puts "week_from_end_matches? == #{week_from_end_matches?(date)}"
		puts "days_left_in_month == #{days_left_in_month(date)}"
		puts "max_day_of_month == #{max_day_of_month(date)}"
	end
end

class RangeEachYearTE < TemporalExpression

	def initialize(start_month, start_day=0, end_month=start_month, end_day=0)
		super()
		@start_month = start_month
		puts "@start_month==#{@start_month}"
		@start_day = start_day
		puts "@start_day==#{@start_day}"
		@end_month = end_month
		puts "@end_month==#{@end_month}"
		@end_day = end_day
		puts "@end_day==#{@end_day}"
	end
	
	def includes?(date)
		months_include?(date) || 
			start_month_includes?(date) || 
				end_month_includes?(date)
	end
	
	def months_include?(date)
		(date.mon > @start_month) && (date.mon < @end_month)
	end

	def end_month_includes?(date)
		return false unless (date.mon == @end_month) 
		(@end_day == 0)  || (date.day <= @end_day)
	end
	
	def start_month_includes?(date)
		return false unless (date.mon == @start_month)		
		(@start_day == 0) || (date.day >= @start_day)
	end
	
	def to_s
		"RangeEachYearTE"
	end

	def print(date)
		puts "DayInMonthTE: #{date}"
		puts "includes? == #{includes?(date)}"
		puts "months_include? == #{months_include?(date)}"
		puts "end_month_includes? == #{end_month_includes?(date)}"
		puts "start_month_includes? == #{start_month_includes?(date)}"
	end
	
end

class RangeEachDayTE < TemporalExpression

	#~ CURRENT_DAY = DatePrecision.
	#~ NEXT_DAY = 

	def initialize(start_hour, start_minute, end_hour, end_minute)
		@start_hour = start_hour
		@start_minute = start_minute
		@end_hour = end_hour
		@end_minute = end_minute
		@spans_midnight = spans_midnight?(start_hour, end_hour)
	end
	
	def includes?(date)
	end
	
	def to_s
		"RangeEachDayTE"
	end
	
	def spans_midnight?(start_hour, end_hour)
		return false unless start_hour <= end_hour
		return true
	end

	def print(date)
		puts "DayInMonthTE: #{date}"
		puts "includes? == #{includes?(date)}"
	end

end

end