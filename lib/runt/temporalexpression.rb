#!/usr/bin/env ruby

=begin
  Author: Matthew Lipper
=end

module Runt

class TemporalExpression

	def includes(aDate)
		false
	end
  
	def log(expr, arg)
		puts "#{to_s}:  #{expr}==#{arg}? #{expr == arg}."
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
  
	def includes(aDate)
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

	def includes(aDate)
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

	def includes(aDate)
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
  
	def includes(aDate)
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
	
	def includes(aDate)
		log(@date_time,aDate)
		return true if @date_time == aDate
		false
	end
	
	def to_s
		"ArbitraryTE"
	end
end

end