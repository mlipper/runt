#!/usr/bin/env ruby

require 'runt'

module Runt
  MONTHS = '(january|february|march|april|may|june|july|august|september|october|november|december)'
  DAYS = '(sunday|monday|tuesday|wednesday|thursday|friday|saturday)'
  ORDINALS = '(first|second|third|fourth|last|second_to_last)'
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
      st_hr, st_min, st_m, end_hr, end_min, end_m = $2, $3, $4, $5, $6, $7
      args = parse_time(st_hr, st_min, st_m)
      args.concat(parse_time(end_hr, end_min, end_m))
      return REDay.new(*args)
    when Regexp.new('^' + DAYS + '$')
      return DIWeek.new(Runt.const(name.to_s))
    when Regexp.new(ORDINALS + '_' + DAYS)
      ordinal, day = $1, $2
      return DIMonth.new(Runt.const(ordinal), Runt.const(day))
    when Regexp.new('^weekly_' + DAYS + '_to_' + DAYS + '$')
      st_day, end_day = $1, $2
      return REWeek.new(Runt.const(st_day), Runt.const(end_day))
    when Regexp.new('^yearly_' + MONTHS + '_(\d{1,2})_to_' + MONTHS + '_(\d{1,2})$')
      st_mon, st_day, end_mon, end_day = $1, $2, $3, $4
      return REYear.new(Runt.const(st_mon), st_day, Runt.const(end_mon), end_day)
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
