#!/usr/bin/env ruby

require 'date'
require 'runt'


module Runt
  # :title:DateRange
  # == DateRange
  #
  #
  # Based the <tt>range</tt>[http://martinfowler.com/ap2/range.html] pattern by Martin Fowler.
  #
  #
  # Author:: Matthew Lipper
  class DateRange < Range

		include DatePrecision

		def initialize(start_expr, end_expr,exclusive=false)
			super(start_expr, end_expr,exclusive)
			@start_expr, @end_expr = start_expr, end_expr
		end

		def include?(obj)
			return super(obj.min)	&& super(obj.max) if obj.kind_of? Range
			return super(obj)
		end

		def min; @start_expr	end
		def max; @end_expr	end
		def to_s;	@start_expr.to_s + " " + @end_expr.to_s end

	end
end