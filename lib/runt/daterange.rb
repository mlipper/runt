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
  #
  # Author:: Matthew Lipper
  class DateRange < Range

    include DPrecision

    attr_reader :start_expr, :end_expr

    def initialize(start_expr, end_expr,exclusive=false)
      super(start_expr, end_expr,exclusive)
      @start_expr, @end_expr = start_expr, end_expr
    end

    def include?(obj)
      return super(obj.min) && super(obj.max) if obj.kind_of? Range
      return super(obj)
    end

    def overlap?(obj)
      return true if( member?(obj) || include?(obj.min) || include?(obj.max) )
      return true if( obj.kind_of?(Range) && obj.include?(self) )
      false
    end

    def empty?
      return @start_expr>@end_expr
    end

    def gap(obj)

      return EMPTY if self.overlap? obj

      lower=nil
      higher=nil

      if((self<=>obj)<0)
        lower=self
        higher=obj
      else
        lower=obj
        higher=self
      end

      return DateRange.new((lower.end_expr+1),(higher.start_expr-1))
    end

    def <=>(other)
      return @start_expr <=> other.start_expr if(@start_expr != other.start_expr)
      return @end_expr <=> other.end_expr
    end

    def min; @start_expr  end
    def max; @end_expr  end
    def to_s; @start_expr.to_s + " " + @end_expr.to_s end


    EMPTY = DateRange.new(PDate.day(2004,2,2),PDate.day(2004,2,1))

  end
end
