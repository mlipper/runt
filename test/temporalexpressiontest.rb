#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt/temporalexpression'
require 'date'

=begin
  Author: Matthew Lipper
=end

class TemporalExpressionTest < Test::Unit::TestCase

	include Runt

	def test_collection_te
    
		#base class that should always return false
		expr = CollectionTE.new
  
		assert(!expr.includes(Date.today))	
	
	end
  
	def test_union_te
    
		dt = Date.new(2003,12,30)

		expr1 = ArbitraryTE.new(dt)
  	
		assert(expr1.includes?(dt))	
	
		dt2 = Date.new(2003,12,31)

		assert(!expr1.includes?(dt2))

		expr2 = ArbitraryTE.new(dt2)
  	
		assert(expr2.includes?(dt2))
		
		union_expr = UnionTE.new
		
		union_expr.add(dt).add(dt2)
		
		assert(union_expr.includes?(dt))
		
		assert(union_expr.includes?(dt2))
	
	end

	#~ def test_ruby_syntax    
    #~		expr = BooleanTE.new
	#~		expr.add("a").add("b").add("c")  
	#~		assert(expr.includes("d"))		
	#~	end

end

#~ class BooleanTE < TemporalExpression

  #~ attr_reader :expressions
  #~ protected :expressions
  
  #~ def initialize
    #~ super
    #~ @expressions = Array.new
  #~ end
  
  #~ def includes(arg)
  
	#~ @expressions.each do |expr|
		#~ puts "#{expr}==#{arg}? #{expr == arg}."
		#~ #return false unless expr == arg 
		#~ return true if expr == arg 
	#~ end
	#~ false
	
  #~ end
  
  #~ def add(arg)
    #~ @expressions.push arg
    #~ self
  #~ end
#~ end