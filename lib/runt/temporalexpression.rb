#!/usr/bin/env ruby

require 'date'
require 'runt/dateprecision'

#
# Author:: Matthew Lipper

module Runt

module TESugar

  def or (arg)

    if self.kind_of?(UnionTE)
      self.add(arg)
    else
      yield UnionTE.new.add(self).add(arg)
    end

  end

  def and (arg)

    if self.kind_of?(IntersectionTE)
      self.add(arg)
    else
      yield IntersectionTE.new.add(self).add(arg)
    end

  end

  def minus (arg)
      yield DifferenceTE.new(self,arg)
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

end

# Base class for all TemporalExpression classes that will probably be scuttled
# unless it proves itself useful in some fashion. Mostly a side-effect of many
# years working with statically typed languages.
#
# TemporalExpressions are inspired by the recurring event
# <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
# described by Martin Fowler. Essentially, they provide a pattern language for
# specifying recurring events using set expressions.
#
# See also [tutorial_te.rdoc]
class TemporalExpression

  include TESugar

  # Returns true or false depending on whether this TemporalExpression includes the supplied
  # date expression.
  def include?(date_expr); false end
  def to_s; "TemporalExpression" end

  protected
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

# Base class for TemporalExpression classes that can be composed of other
# TemporalExpression objects imlpemented using the <tt>Composite(GoF)</tt> pattern.
class CollectionTE < TemporalExpression

  attr_reader :expressions
  protected :expressions

  def initialize
    @expressions = Array.new
  end

  def add(anExpression)
    @expressions.push anExpression
    self
  end

  def to_s; "CollectionTE" end
end

# Composite TemporalExpression that will be true if <b>any</b> of it's
# component expressions are true.
class UnionTE < CollectionTE

  def include?(aDate)
    @expressions.each do |expr|
      return true if expr.include?(aDate)
    end
    false
  end

  def to_s; "UnionTE" end
end

# Composite TemporalExpression that will be true only if <b>all</b> it's
# component expressions are true.
class IntersectionTE < CollectionTE

  def include?(aDate)
    #Handle @expressions.size==0
    result = false
    @expressions.each do |expr|
      return false unless (result = expr.include?(aDate))
    end
    result
  end

  def to_s; "IntersectionTE" end
end

# TemporalExpression that will be true only if the first of
# it's two contained expressions is true and the second is false.
class DifferenceTE < TemporalExpression

  def initialize(expr1, expr2)
    @expr1 = expr1
    @expr2 = expr2
  end

  def include?(aDate)
    return false unless (@expr1.include?(aDate) && !@expr2.include?(aDate))
    true
  end

  def to_s; "DifferenceTE" end
end

# TemporalExpression that provides for inclusion of an arbitrary date.
class ArbitraryTE < TemporalExpression

  def initialize(date_expr)
    @date_expr = date_expr
  end

  # Will return true if the supplied object is == to that which was used to
  # create this instance
  def include?(date_expr)
    return true if @date_expr == date_expr
    false
  end

  def to_s; "ArbitraryTE" end

end

# TemporalExpression that provides a thin wrapper around built-in Ruby <tt>Range</tt> functionality
# facilitating inclusion of an arbitrary range in a temporal expression.
#
#  See also: Range
class ArbitraryRangeTE < TemporalExpression

  def initialize(date_expr)
    raise TypeError, 'expected range' unless date_expr.kind_of?(Range)
    @date_expr = date_expr
  end

  # Will return true if the supplied object is included in the range used to
  # create this instance
  def include?(date_expr)
    return @date_expr.include?(date_expr)
  end

  def to_s; "ArbitraryRangeTE" end
end

# TemporalExpression that provides support for building a temporal
# expression using the form:
#
#     DayInMonthTE.new(1,0)
#
# where the first argument is the week of the month and the second
# argument is the wday of the week as defined by the 'wday' method
# in the standard library class Date.
#
# A negative value for the week of the month argument will count
# backwards from the end of the month. So, to match the last Saturday
# of the month
#
#     DayInMonthTE.new(-1,6)
#
# Using constants defined in the base Runt module, you can re-write
# the first example above as:
#
#     DayInMonthTE.new(First,Sunday)
#
# and the second as:
#
#     DayInMonthTE.new(Last,Saturday)
#
#  See also: Date, Runt
class DayInMonthTE < TemporalExpression

  def initialize(week_of_month_index,day_index)
    @day_index = day_index
    @week_of_month_index = week_of_month_index
  end

  def include?(date)
    ( day_matches?(date) ) && ( week_matches?(@week_of_month_index,date) )
  end

  def to_s
    "DayInMonthTE"
  end

  def print(date)
    puts "DayInMonthTE: #{date}"
    puts "include? == #{include?(date)}"
    puts "day_matches? == #{day_matches?(date)}"
    puts "week_matches? == #{week_matches?(date)}"
    puts "week_from_start_matches? == #{week_from_start_matches?(date)}"
    puts "week_from_end_matches? == #{week_from_end_matches?(date)}"
    puts "days_left_in_month == #{days_left_in_month(date)}"
    puts "max_day_of_month == #{max_day_of_month(date)}"
  end

  private
  def day_matches?(date)
    @day_index == date.wday
  end

end

# TemporalExpression that matches days of the week where the first argument
# is an integer denoting the ordinal day of the week. Valid values are 0..6 where
# 0 == Sunday and 6==Saturday
#
# For example:
#
#     DayInWeekhTE.new(0)
#
# Using constants defined in the base Runt module, you can re-write
# the first example above as:
#
#     DayInWeekhTE.new(Sunday)
#
#  See also: Date, Runt
class DayInWeekTE < TemporalExpression

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

end

# TemporalExpression that matches days of the week within one
# week only.
#
# If start and end day are equal, the entire week will match true.
#
#  See also: Date
class RangeEachWeekTE < TemporalExpression

  VALID_RANGE = 0..6

	# Creates a RangeEachWeekTE using the supplied start
  # day(range = 0..6, where 0=>Sunday) and an optional end
  # day. If an end day is not supplied, the maximum value
  # (6 => Saturday) is assumed.
  #
  # If the start day is greater than the end day, an
	# ArgumentError will be raised
	def initialize(start_day,end_day=6)
		super()
		validate(start_day,end_day)
    @start_day = start_day
    @end_day = end_day
  end

  def include?(date)
    return true if  @start_day==@end_day
    @start_day<=date.wday && @end_day>=date.wday
  end

  def to_s
    "RangeEachWeekTE"
  end

	private
  def validate(start_day,end_day)
    unless start_day<=end_day
      raise ArgumentError, 'end day of week must be greater than start day'
    end
    unless VALID_RANGE.include?(start_day)&&VALID_RANGE.include?(end_day)
      raise ArgumentError, 'start and end day arguments must be in the range #{VALID_RANGE.to_s}.'
    end
  end
end

class RangeEachYearTE < TemporalExpression

  def initialize(start_month, start_day=0, end_month=start_month, end_day=0)
    super()
    @start_month = start_month
    @start_day = start_day
    @end_month = end_month
    @end_day = end_day
  end

  def include?(date)
    months_include?(date) ||
      start_month_include?(date) ||
        end_month_include?(date)
  end

  def to_s
    "RangeEachYearTE"
  end

  def print(date)
    puts "DayInMonthTE: #{date}"
    puts "include? == #{include?(date)}"
    puts "months_include? == #{months_include?(date)}"
    puts "end_month_include? == #{end_month_include?(date)}"
    puts "start_month_include? == #{start_month_include?(date)}"
  end

  private
  def months_include?(date)
    (date.mon > @start_month) && (date.mon < @end_month)
  end

  def end_month_include?(date)
    return false unless (date.mon == @end_month)
    (@end_day == 0)  || (date.day <= @end_day)
  end

  def start_month_include?(date)
    return false unless (date.mon == @start_month)
    (@start_day == 0) || (date.day >= @start_day)
  end
end

# TemporalExpression that matches periods of the day with minute
# precision. If the start hour is greater than the end hour, than end hour
# is assumed to be on the following day.
#
#  See also: Date
class RangeEachDayTE < TemporalExpression

  CURRENT=28
  NEXT=29
  ANY_DATE=TimePoint.day_of_month(2002,8,CURRENT)

  def initialize(start_hour, start_minute, end_hour, end_minute)

    start_time = TimePoint.minute(ANY_DATE.year,ANY_DATE.month,
              ANY_DATE.day,start_hour,start_minute)

    if(@spans_midnight = spans_midnight?(start_hour, end_hour)) then
      end_time = get_next(end_hour,end_minute)
    else
      end_time = get_current(end_hour,end_minute)
    end

    @range = start_time..end_time
  end

  def include?(date)
    raise TypeError, 'expected date' unless date.kind_of?(Date)

    if(@spans_midnight&&date.hour<12) then
      #Assume next day
      return @range.include?(get_next(date.hour,date.min))
    end

    #Same day
    return @range.include?(get_current(date.hour,date.min))
  end

  def to_s
    "RangeEachDayTE"
  end

  def print(date)
    puts "DayInMonthTE: #{date}"
    puts "include? == #{include?(date)}"
  end

  private
  def spans_midnight?(start_hour, end_hour)
    return end_hour <= start_hour
  end

  private
  def get_current(hour,minute)
      TimePoint.minute(ANY_DATE.year,ANY_DATE.month,CURRENT,hour,minute)
  end

  def get_next(hour,minute)
      TimePoint.minute(ANY_DATE.year,ANY_DATE.month,NEXT,hour,minute)
  end

end

# TemporalExpression that matches the week in a month. For example:
#
#     WeekInMonthTE.new(1)
#
#  See also: Date
class WeekInMonthTE < TemporalExpression

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

end

end
