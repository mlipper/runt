#!/usr/bin/env ruby

require 'date'
require 'runt/dprecision'
require 'runt/pdate'
require 'pp'

#
# Author:: Matthew Lipper

module Runt

#
# 'TExpr' is short for 'TemporalExpression' and are inspired by the recurring event
# <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
# described by Martin Fowler. Essentially, they provide a pattern language for
# specifying recurring events using set expressions.
#
# See also [tutorial_te.rdoc]
module TExpr

  # Returns true or false depending on whether this TExpr includes the supplied
  # date expression.
  def include?(date_expr); false end
  
  def to_s; "TExpr" end

  def or (arg)

    if self.kind_of?(Union)
      self.add(arg)
    else
      yield Union.new.add(self).add(arg)
    end

  end

  def and (arg)

    if self.kind_of?(Intersect)
      self.add(arg)
    else
      yield Intersect.new.add(self).add(arg)
    end

  end

  def minus (arg)
      yield Diff.new(self,arg)
  end

  def | (expr)
    self.or(expr){|adjusted| adjusted }
  end

  def & (expr)
    self.and(expr){|adjusted| adjusted }
  end

  def - (expr)
    self.minus(expr){|adjusted| adjusted }
  end

  # Contributed by Emmett Shear:
  # Returns an Array of Date-like objects which occur within the supplied
  # DateRange.  Will stop calculating dates once a number of dates equal 
  # to the optional attribute limit are found. (A limit of zero will collect
  # all matching dates in the date range.)
  def dates(date_range, limit=0)
    result = []
    date_range.each do |date|
      result << date if self.include? date
      if limit > 0 and result.size == limit
        break
      end
    end
    result
  end

end

# Base class for TExpr classes that can be composed of other
# TExpr objects imlpemented using the <tt>Composite(GoF)</tt> pattern.
class Collection 
  
  include TExpr
  
  attr_reader :expressions

  def initialize
    @expressions = Array.new
  end

  def add(anExpression)
    @expressions.push anExpression
    self
  end

  # Will return true if the supplied object overlaps with the range used to
  # create this instance
  def overlap?(date_expr)
    @expressions.each do | interval |
      return true if date_expr.overlap?(interval)      
    end
    false    
  end

  def to_s
    if !@expressions.empty? && block_given?
      first_expr, next_exprs = yield
      result = '' 
      @expressions.map do |expr|
	if @expressions.first===expr
	  result = first_expr + expr.to_s
	else
	 result = result + next_exprs + expr.to_s
	end 
      end
      result
    else
      'empty'
    end
  end

  def display
    puts "I am a #{self.class} containing:"
    @expressions.each do |ex| 
      pp "#{ex.class}"
    end
  end

  
end

# Composite TExpr that will be true if <b>any</b> of it's
# component expressions are true.
class Union < Collection

  def include?(aDate)
    @expressions.each do |expr|
      return true if expr.include?(aDate)
    end
    false
  end

  def to_s
    super {['every ',' or ']}
  end
end

# Composite TExpr that will be true only if <b>all</b> it's
# component expressions are true.
class Intersect < Collection

  def include?(aDate)
    result = false
    @expressions.each do |expr|
      return false unless (result = expr.include?(aDate))
    end
    result
  end

  def to_s 
    super {['every ', ' and ']}  
  end
end

# TExpr that will be true only if the first of
# its two contained expressions is true and the second is false.
class Diff 

  include TExpr

  attr_reader :expr1, :expr2

  def initialize(expr1, expr2)
    @expr1 = expr1
    @expr2 = expr2
  end

  def include?(aDate)
    return false unless (@expr1.include?(aDate) && !@expr2.include?(aDate))
    true
  end

  def to_s
    @expr1.to_s + ' except for ' + @expr2.to_s
  end
end

# TExpr that provides for inclusion of an arbitrary date.
class Spec
  
  include TExpr

  attr_reader :date_expr
  
  def initialize(date_expr)
    @date_expr = date_expr
  end

  # Will return true if the supplied object is == to that which was used to
  # create this instance
  def include?(date_expr)
    return date_expr.include?(@date_expr) if date_expr.respond_to?(:include?)
    return true if @date_expr == date_expr
    false
  end

  def to_s
    @date_expr.to_s
  end

end

# TExpr that provides a thin wrapper around built-in Ruby <tt>Range</tt> functionality
# facilitating inclusion of an arbitrary range in a temporal expression.
#
#  See also: Range
class RSpec < Spec 

  ## Will return true if the supplied object is included in the range used to
  ## create this instance
  def include?(date_expr)
    return @date_expr.include?(date_expr)
  end
  
  # Will return true if the supplied object overlaps with the range used to
  # create this instance
  def overlap?(date_expr)
    @date_expr.each do | interval |
      return true if date_expr.include?(interval)      
    end
    false    
  end

end

#######################################################################
# Utility methods common to some expressions

module TExprUtils
  def week_in_month(day_in_month)
    ((day_in_month - 1) / 7) + 1
  end

  def days_left_in_month(date)
    return max_day_of_month(date) - date.day
  end

  def max_day_of_month(date)
    result = 1
    next_month = nil
    if(date.mon==12)
      next_month = Date.new(date.year+1,1,1)
    else
      next_month = Date.new(date.year,date.mon+1,1)
    end
    date.step(next_month,1){ |d| result=d.day unless d.day < result }
    result
  end

  def week_matches?(index,date)
    if(index > 0)
      return week_from_start_matches?(index,date)
    else
      return week_from_end_matches?(index,date)
    end
  end

  def week_from_start_matches?(index,date)
    week_in_month(date.day)==index
  end

  def week_from_end_matches?(index,date)
    n = days_left_in_month(date) + 1
    week_in_month(n)==index.abs
  end

end

# TExpr that provides support for building a temporal
# expression using the form:
#
#     DIMonth.new(1,0)
#
# where the first argument is the week of the month and the second
# argument is the wday of the week as defined by the 'wday' method
# in the standard library class Date.
#
# A negative value for the week of the month argument will count
# backwards from the end of the month. So, to match the last Saturday
# of the month
#
#     DIMonth.new(-1,6)
#
# Using constants defined in the base Runt module, you can re-write
# the first example above as:
#
#     DIMonth.new(First,Sunday)
#
# and the second as:
#
#     DIMonth.new(Last,Saturday)
#
#  See also: Date, Runt
class DIMonth 

  include TExpr
  include TExprUtils

  def initialize(week_of_month_index,day_index)
    @day_index = day_index
    @week_of_month_index = week_of_month_index
  end

  def include?(date)
    ( day_matches?(date) ) && ( week_matches?(@week_of_month_index,date) )
  end

  def to_s
    "#{Runt.ordinalize(@week_of_month_index)} #{Runt.day_name(@day_index)} of the month"
  end

  private
  def day_matches?(date)
    @day_index == date.wday
  end

end

# TExpr that matches days of the week where the first argument
# is an integer denoting the ordinal day of the week. Valid values are 0..6 where
# 0 == Sunday and 6==Saturday
#
# For example:
#
#     DIWeek.new(0)
#
# Using constants defined in the base Runt module, you can re-write
# the first example above as:
#
#     DIWeek.new(Sunday)
#
#  See also: Date, Runt
class DIWeek 

  include TExpr

  VALID_RANGE = 0..6

  def initialize(ordinal_weekday)
    unless VALID_RANGE.include?(ordinal_weekday)
      raise ArgumentError, 'invalid ordinal day of week'
    end
    @ordinal_weekday = ordinal_weekday
  end

  def include?(date)
    @ordinal_weekday == date.wday
  end

  def to_s
    "#{Runt.day_name(@ordinal_weekday)}"
  end

end

# TExpr that matches days of the week within one
# week only.
#
# If start and end day are equal, the entire week will match true.
#
#  See also: Date
class REWeek 

  include TExpr

  VALID_RANGE = 0..6

  # Creates a REWeek using the supplied start
  # day(range = 0..6, where 0=>Sunday) and an optional end
  # day. If an end day is not supplied, the maximum value
  # (6 => Saturday) is assumed.
  def initialize(start_day,end_day=6)
    validate(start_day,end_day)
    @start_day = start_day
    @end_day = end_day
  end

  def include?(date)
    return true if all_week?
    if @start_day < @end_day
      @start_day<=date.wday && @end_day>=date.wday
    else
      (@start_day<=date.wday && 6 >=date.wday) || (0 <=date.wday && @end_day >=date.wday)
    end
  end

  def to_s
    return "all week" if all_week?
    "#{Runt.day_name(@start_day)} through #{Runt.day_name(@end_day)}" 
  end

  private
  
  def all_week?
    return true if  @start_day==@end_day
  end
    
  def validate(start_day,end_day)
    unless VALID_RANGE.include?(start_day)&&VALID_RANGE.include?(end_day)
      raise ArgumentError, 'start and end day arguments must be in the range #{VALID_RANGE.to_s}.'
    end
  end
end

#
# TExpr that matches date ranges within a single year. Assumes that the start 
# and end parameters occur within the same year. 
#
#
class REYear 

  # Sentinel value used to denote that no specific day was given to create
  # the expression.
  NO_DAY = 0

  include TExpr

  attr_accessor :start_month, :start_day, :end_month, :end_day
  
  #
  # == Synopsis
  # 
  #   REYear.new(start_month [, (start_day | end_month), ...]
  #
  # == Args
  # 
  # One or two arguments given::
  #
  # +start_month+::
  #   Start month. Valid values are 1..12. When no other parameters are given 
  #   this value will be used for the end month as well. Matches the entire
  #   month through the ending month.
  # +end_month+::
  #   End month. Valid values are 1..12. When given in two argument form
  #   will match through the entire month.   
  # 
  # Three or four arguments given::
  #
  # +start_month+::
  #   Start month. Valid values are 1..12.
  # +start_day+::
  #   Start day. Valid values are 1..31, depending on the month.
  # +end_month+::
  #   End month. Valid values are 1..12. If a fourth argument is not given,
  #   this value will cover through the entire month.
  # +end_day+::
  #   End day. Valid values are 1..31, depending on the month.
  # 
  # == Description
  #
  # Create a new REYear expression expressing a range of months or days 
  # within months within a year.
  #
  # == Usage
  #
  #   # Creates the range March 12th through May 23rd
  #   expr = REYear.new(3,12,5,23)
  #
  #   # Creates the range March 1st through May 31st
  #   expr = REYear.new(3,5)
  #
  #   # Creates the range March 12th through May 31st
  #   expr = REYear.new(3,12,5)
  #
  #   # Creates the range March 1st through March 30th
  #   expr = REYear.new(3)
  #
  def initialize(start_month, *args)
    @start_month = start_month
    if (args.nil? || args.size == NO_DAY) then
      # One argument given
      @end_month = start_month
      @start_day = NO_DAY
      @end_day = NO_DAY
    else
      case args.size
      when 1
	@end_month = args[0]
	@start_day = NO_DAY
	@end_day = NO_DAY
      when 2
	@start_day = args[0]
	@end_month = args[1]
	@end_day = NO_DAY
      when 3
	@start_day = args[0]
	@end_month = args[1]
	@end_day = args[2]
      else
	raise "Invalid number of var args: 1 or 3 expected, #{args.size} given"
      end
    end
    @same_month_dates_provided = (@start_month == @end_month) && (@start_day!=NO_DAY && @end_day != NO_DAY)
  end

  def include?(date)
   
    return same_start_month_include_day?(date) \
      && same_end_month_include_day?(date) if @same_month_dates_provided

    is_between_months?(date) ||
      (same_start_month_include_day?(date) ||
	same_end_month_include_day?(date))
  end

  def save
    "Runt::REYear.new(#{@start_month}, #{@start_day}, #{@end_month}, #{@end_day})"
  end

  def to_s
    "#{Runt.month_name(@start_month)} #{Runt.ordinalize(@start_day)} " +
      "through #{Runt.month_name(@end_month)} #{Runt.ordinalize(@end_day)}"
  end

  private
  def is_between_months?(date)
    (date.mon > @start_month) && (date.mon < @end_month)
  end

  def same_end_month_include_day?(date)
    return false unless (date.mon == @end_month)
    (@end_day == NO_DAY)  || (date.day <= @end_day)
  end

  def same_start_month_include_day?(date)
    return false unless (date.mon == @start_month)
    (@start_day == NO_DAY) || (date.day >= @start_day)
  end

end

# TExpr that matches periods of the day with minute
# precision. If the start hour is greater than the end hour, than end hour
# is assumed to be on the following day.
#
#  See also: Date
class REDay 

  include TExpr

  CURRENT=28
  NEXT=29
  ANY_DATE=PDate.day(2002,8,CURRENT)

  def initialize(start_hour, start_minute, end_hour, end_minute)

    start_time = PDate.min(ANY_DATE.year,ANY_DATE.month,
              ANY_DATE.day,start_hour,start_minute)

    if(@spans_midnight = spans_midnight?(start_hour, end_hour)) then
      end_time = get_next(end_hour,end_minute)
    else
      end_time = get_current(end_hour,end_minute)
    end

    @range = start_time..end_time
  end

  def include?(date)
    # 2007-11-9: Not completely sure of the implications of commenting this 
    # out but...
    # 
    # If precision is day or greater, then the result is always true
    #return true if date.date_precision <= DPrecision::DAY
    
    if(@spans_midnight&&date.hour<12) then
      #Assume next day
      return @range.include?(get_next(date.hour,date.min))
    end

    #Same day
    return @range.include?(get_current(date.hour,date.min))
  end

  def to_s
    "from #{Runt.format_time(@range.begin)} to #{Runt.format_time(@range.end)} daily"
  end

  private
  def spans_midnight?(start_hour, end_hour)
    #puts "spans midnight? #{end_hour < start_hour} (end==#{end_hour} <= start==#{start_hour})"
    #return end_hour <= start_hour
    return end_hour < start_hour
  end

  def get_current(hour,minute)
      PDate.min(ANY_DATE.year,ANY_DATE.month,CURRENT,hour,minute)
  end

  def get_next(hour,minute)
      PDate.min(ANY_DATE.year,ANY_DATE.month,NEXT,hour,minute)
  end

end

# TExpr that matches the week in a month. For example:
#
#     WIMonth.new(1)
#
#  See also: Date
#  FIXME .dates mixin seems functionally broken
class WIMonth 

  include TExpr
  include TExprUtils

  VALID_RANGE = -2..5

  def initialize(ordinal)
    unless VALID_RANGE.include?(ordinal)
      raise ArgumentError, 'invalid ordinal week of month'
    end
    @ordinal = ordinal
  end

  def include?(date)
    week_matches?(@ordinal,date)
  end

  def to_s
    "#{Runt.ordinalize(@ordinal)} week of any month"
  end

end

# TExpr that matches a range of dates within a month. For example:
# 
#     REMonth.(12,28)
#
# matches from the 12th thru the 28th of any month. If end_day==0
# or is not given, start_day will define the range with that single day.
# 
#  See also: Date
class REMonth

  include TExpr

  def initialize(start_day, end_day=0)
    end_day=start_day if end_day==0
    @range = start_day..end_day
  end

  def include?(date)
    @range.include? date.mday
  end

  def to_s
    "from the #{Runt.ordinalize(@range.begin)} to the #{Runt.ordinalize(@range.end)} monthly"
  end

end

# 
# Using the precision from the supplied start argument and the its date value,
# matches every n number of time units thereafter.
#
class EveryTE

  include TExpr

  def initialize(start,n,precision=nil)
    @start=start
    @interval=n
    # Use the precision of the start date by default
    @precision=precision || @start.date_precision
  end

  def include?(date)
    i=DPrecision.to_p(@start,@precision)
    d=DPrecision.to_p(date,@precision)
    while i<=d
      return true if i.eql?(d)
      i=i+@interval      
    end
    false
  end

  def to_s
    "every #{@interval} #{@precision.label.downcase}s starting #{Runt.format_date(@start)}"
  end

end

# Using day precision dates, matches every n number of days after a  given 
# base date. All date arguments are converted to DPrecision::DAY precision. 
#
# Contributed by Ira Burton
class DayIntervalTE

  include TExpr

  def initialize(base_date,n)
    @base_date = DPrecision.to_p(base_date,DPrecision::DAY)
    @interval = n
  end

  def include?(date)
    return ((DPrecision.to_p(date,DPrecision::DAY) - @base_date).to_i % @interval == 0)   
  end

  def to_s
    "every #{Runt.ordinalize(@interval)} day after #{Runt.format_date(@base_date)}"
  end

end

# Simple expression which returns true if the supplied arguments
# occur within the given year.
#
class YearTE

  include TExpr

  def initialize(year)
    @year = year
  end

  def include?(date)
    return date.year == @year
  end

  def to_s
    "during the year #{@year}"
  end

end

# Matches dates that occur before a given date.
class BeforeTE

  include TExpr

  def initialize(date, inclusive=false)
    @date = date
    @inclusive = inclusive
  end

  def include?(date)
    return (date < @date) || (@inclusive && @date == date)
  end

  def to_s
    "before #{Runt.format_date(@base_date)}"
  end

end

# Matches dates that occur after a given date.
class AfterTE

  include TExpr

  def initialize(date, inclusive=false)
    @date = date
    @inclusive = inclusive
  end

  def include?(date)
    return (date > @date) || (@inclusive && @date == date)
  end

  def to_s
    "before #{Runt.format_date(@base_date)}"
  end

end

end
