#!/usr/bin/env ruby

# :title:Runt -- Ruby Temporal Expressions
#
# == Runt -- Ruby Temporal Expressions
#
# The usage and design patterns expressed in this library are mostly...*uhm*..
# <em>entirely</em>..*cough*...based on a series of
# <tt>articles</tt>[http://www.martinfowler.com] by Martin Fowler.
#
# It highly recommended that anyone using Runt (or writing
# object-oriented software :) take a moment to peruse the wealth of useful info
# that Fowler has made publicly available:
#
# * An excellent introductory summation of temporal <tt>patterns</tt>[http://martinfowler.com/ap2/timeNarrative.html]
# * Recurring event <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
#
# Also, for those of you (like me, for example) still chained in your cubicle and forced
# to write <tt>Java</tt>[http://java.sun.com] code, check out the original version of
# project called <tt>ChronicJ</tt>[http://chronicj.org].
#
# ---
# Author::    Matthew Lipper (mailto:mlipper@gmail.com)
# Copyright:: Copyright (c) 2004 Digital Clash, LLC
# License::   See LICENSE.txt
#
# = Warranty
#
# This software is provided "as is" and without any express or
# implied warranties, including, without limitation, the implied
# warranties of merchantibility and fitness for a particular
# purpose.

require 'time'
require 'date'
require 'date/format'
require "runt/dprecision"
require "runt/pdate"
require "runt/temporalexpression"
require "runt/schedule"
require "runt/daterange"

#
# The Runt module is the main namespace for all Runt modules and classes. Using
# require statements, it makes the entire Runt library available.It also
# defines some new constants and exposes some already defined in the standard
# library classes <tt>Date</tt> and <tt>DateTime</tt>.
#
# <b>See also</b> date.rb
#
module Runt
  
  class << self
    
    def day_name(number)
      Date::DAYNAMES[number]
    end
    
    def month_name(number)
      Date::MONTHNAMES[number]
    end

    def format_time(date)
      date.strftime('%I:%M%p')
    end

    def format_date(date)
      date.ctime
    end
    
    #
    # Cut and pasted from activesupport-1.2.5/lib/inflector.rb
    #
    def ordinalize(number)
      if (number.to_i==-1)
	'last'
      elsif (number.to_i==-2)
	'second to last'  
      elsif (11..13).include?(number.to_i % 100)
	"#{number}th"
      else
	case number.to_i % 10
	  when 1: "#{number}st"
	  when 2: "#{number}nd"
	  when 3: "#{number}rd"
	  else    "#{number}th"
	end
      end
    end

  end

  #Yes it's true, I'm a big idiot!
  Sunday = Date::DAYNAMES.index("Sunday")
  Monday = Date::DAYNAMES.index("Monday")
  Tuesday = Date::DAYNAMES.index("Tuesday")
  Wednesday = Date::DAYNAMES.index("Wednesday")
  Thursday = Date::DAYNAMES.index("Thursday")
  Friday = Date::DAYNAMES.index("Friday")
  Saturday = Date::DAYNAMES.index("Saturday")
  Sun = Date::ABBR_DAYNAMES.index("Sun")
  Mon = Date::ABBR_DAYNAMES.index("Mon")
  Tue = Date::ABBR_DAYNAMES.index("Tue")
  Wed = Date::ABBR_DAYNAMES.index("Wed")
  Thu = Date::ABBR_DAYNAMES.index("Thu")
  Fri = Date::ABBR_DAYNAMES.index("Fri")
  Sat = Date::ABBR_DAYNAMES.index("Sat")
  First = 1
  Second = 2
  Third = 3
  Fourth = 4
  Fifth = 5
  Sixth = 6
  Seventh = 7
  Eigth = 8
  Ninth = 9
  Tenth = 10

  private
  class ApplyLast #:nodoc:
    def initialize
      @negate=Proc.new{|n| n*-1}
    end
    def [](arg)
      @negate.call(arg)
    end
  end
  LastProc = ApplyLast.new

  public
  Last = LastProc[First]
  Last_of = LastProc[First]
  Second_to_last = LastProc[Second]

end

#
# Add precision +Runt::DPrecision+ to standard library classes Date and DateTime 
# (which is a subclass of Date). Also, add an inlcude? method for interoperability
# with +Runt::TExpr+ classes
#
class Date

  include Runt

  attr_accessor :date_precision

  def include?(expr)
    eql?(expr)
  end

  def date_precision
    return @date_precision unless @date_precision.nil? 
    return Runt::DPrecision::DEFAULT 
  end 	  
end

#
# Add the ability to use Time class 
#
# Contributed by Paul Wright
#
class Time
  
  include Runt

  attr_accessor :date_precision

  def initialize(*args)
    if(args[0].instance_of?(Runt::DPrecision::Precision))
      @precision=args.shift
    else
      @precision=Runt::DPrecision::DEFAULT
    end
    super(*args)
  end

  class << self
    alias_method :old_parse, :parse
    def parse(*args)
      precision=Runt::DPrecision::DEFAULT
      if(args[0].instance_of?(Runt::DPrecision::Precision))
        precision=args.shift
      end
      _parse=old_parse(*args)
      _parse.date_precision=precision
      _parse
    end
  end

  #def date_precision
  #  return @date_precision unless @date_precision.nil?
  #  return Runt::DPrecision::DEFAULT
  #end
end

#
# Useful shortcuts!
#
# Contributed by Ara T. Howard who is pretty sure he got the idea from 
# somewhere else. :-)
#
class Numeric #:nodoc:
  def microseconds() Float(self  * (10 ** -6)) end
  def milliseconds() Float(self  * (10 ** -3)) end
  def seconds() self end
  def minutes() 60 * seconds end
  def hours() 60 * minutes end
  def days() 24 * hours end
  def weeks() 7 * days end
  def months() 30 * days end
  def years() 365 * days end
  def decades() 10 * years end
  # This causes RDoc to hurl:  
  %w[
  microseconds milliseconds seconds minutes hours days weeks months years decades
  ].each{|m| alias_method m.chop, m}
end

