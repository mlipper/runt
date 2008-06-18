#!/usr/bin/env ruby

require 'runt'

module Runt
  ORDINALS = ['first', 'second', 'third', 'fourth', 'last','second_to_last']
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
    days = '(monday|tuesday|wednesday|thursday|friday|saturday|sunday)'
    ordinals = '(first|second|third|fourth|last|second_to_last)'
    case name.to_s
    when /^(daily_)(\d{1,2})_(\d{2})([ap]m)_to_(\d{1,2})_(\d{2})([ap]m)$/
      st_hr, st_min, st_m, end_hr, end_min, end_m = $2, $3, $4, $5, $6, $7
      args = parse_time(st_hr, st_min, st_m)
      args.concat(parse_time(end_hr, end_min, end_m))
      return REDay.new(*args)
    when Regexp.new('^' + days + '$')
      return DIWeek.new(Runt.const(name.to_s))
    when Regexp.new(ordinals + '_' + days)
      ordinal, day = $1, $2
      return DIMonth.new(Runt.const(ordinal), Runt.const(day))
    end
  end

  def parse_time(hour, minute, ampm)
    hour = hour.to_i + 12 if ampm =~ /pm/
    [hour.to_i, minute.to_i]
  end
end
