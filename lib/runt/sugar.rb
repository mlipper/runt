#!/usr/bin/env ruby

require 'runt'

#
# 
# == Overview
# 
#  This file provides an optional extension to the Runt module which 
#  provides convenient shortcuts for commonly used temporal expressions.
#  
#  Several methods for creating new temporal expression instances are added
#  to a client class by including the Runt module.
#
# === Shortcuts
#  
#  Shortcuts are implemented by pattern matching done in method_missing for 
#  the Runt module. Generally speaking, range expressions start with "daily_", 
#  "weekly_", "yearly_", etc.   
#
#  Times use the format /\d{1,2}_\d{2}[ap]m/ where the first digits represent hours
#  and the second digits represent minutes. Note that hours are always within the
#  range of 1-12 and may be one or two digits. Minutes are always two digits 
#  (e.g. '03' not just '3') and are always followed by am or pm (lowercase).
#  
#
#  class MyClass
#    include Runt
#  
#    def some_method
#      # Daily from 4:02pm to 10:20pm or anytime Tuesday
#      expr = daily_4_02pm_to_10_20pm() | tuesday()   
#      ...
#    end
#    ...
#  end
#  
#  The following documents the syntax for particular temporal expression classes.
#
# === REDay 
#  
#    daily_<start hour>_<start minute>_to_<end hour>_<end minute>
#  
#  Example:
#
#    self.daily_10_00am_to_1:30pm() 
#
#  is equivilant to 
#
#    REDay.new(10,00,13,30)
# 
# === REWeek
#  
#    weekly_<start day>_to_<end day>
#  
#  Example:
#
#    self.weekly_tuesday_to_thrusday()
#
#  is equivilant to 
#
#    REWeek.new(Tuesday, Thrusday)
# 
# === REMonth
#  
#    monthly_<start numeric ordinal>_to_<end numeric ordinal>
#  
#  Example:
#
#    self.monthly_23rd_to_29th()
#
#  is equivilant to 
#
#    REMonth.new(23, 29)
# 
# === REYear
#  
#    self.yearly_<start month>_<start day>_to_<end month>_<end day>()
#  
#  Example:
#
#    self.yearly_march_15_to_june_1()
#
#  is equivilant to 
#
#    REYear.new(March, 15, June, 1)
# 
# === DIWeek
#  
#    self.<day name>()
#  
#  Example:
#
#    self.friday()
#
#  is equivilant to 
#
#    DIWeek.new(Friday)
# 
# === DIMonth
#  
#    self.<lowercase ordinal>_<day name>()
#  
#  Example:
#
#    self.first_saturday()
#    self.last_tuesday()
#
#  is equivilant to 
#
#    DIMonth.new(First, Saturday)
#    DIMonth.new(Last, Tuesday)
# 
module Runt
  MONTHS = '(january|february|march|april|may|june|july|august|september|october|november|december)'
  DAYS = '(sunday|monday|tuesday|wednesday|thursday|friday|saturday)'
  WEEK_OF_MONTH_ORDINALS = '(first|second|third|fourth|last|second_to_last)'
  ORDINAL_SUFFIX = '(?:st|nd|rd|th)'
  ORDINAL_ABBR = '(st|nd|rd|th)'
  class << self 
    def const(string)
      self.const_get(string.capitalize)
    end
  end

  def method_missing(name, *args, &block) 
    #puts "Called '#{name}' with #{args.inspect} and #{block}"
    result = self.build(name, *args, &block)
    return result unless result.nil?
    super(name, *args, &block)
  end

  def build(name, *args, &block)
    case name.to_s
    when /^(daily_)(\d{1,2})_(\d{2})([ap]m)_to_(\d{1,2})_(\d{2})([ap]m)$/
      # REDay
      st_hr, st_min, st_m, end_hr, end_min, end_m = $2, $3, $4, $5, $6, $7
      args = parse_time(st_hr, st_min, st_m)
      args.concat(parse_time(end_hr, end_min, end_m))
      return REDay.new(*args)
    when Regexp.new('^weekly_' + DAYS + '_to_' + DAYS + '$')
      # REWeek
      st_day, end_day = $1, $2
      return REWeek.new(Runt.const(st_day), Runt.const(end_day))
    when Regexp.new('^monthly_(\d{1,2})' + ORDINAL_SUFFIX + '_to_(\d{1,2})' \
		    + ORDINAL_SUFFIX + '$')
      # REMonth
      st_day, end_day = $1, $2
      return REMonth.new(st_day, end_day)
    when Regexp.new('^yearly_' + MONTHS + '_(\d{1,2})_to_' + MONTHS + '_(\d{1,2})$')
      # REYear
      st_mon, st_day, end_mon, end_day = $1, $2, $3, $4
      return REYear.new(Runt.const(st_mon), st_day, Runt.const(end_mon), end_day)
    when Regexp.new('^' + DAYS + '$')
      # DIWeek
      return DIWeek.new(Runt.const(name.to_s))
    when Regexp.new(WEEK_OF_MONTH_ORDINALS + '_' + DAYS)
      # DIMonth
      ordinal, day = $1, $2
      return DIMonth.new(Runt.const(ordinal), Runt.const(day))
    else
      # You're hosed
      nil
    end
  end

  def parse_time(hour, minute, ampm)
    hour = hour.to_i + 12 if ampm =~ /pm/
    [hour.to_i, minute.to_i]
  end
end
