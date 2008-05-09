#!/usr/bin/env ruby

require 'runt'
require 'date'

module Runt

  # :title:DPrecision
  # == DPrecision
  # Module providing automatic precisioning of Date, DateTime, and PDate classes.
  #
  # Inspired by a <tt>pattern</tt>[http://martinfowler.com/ap2/timePoint.html] by Martin Fowler.
  #
  #
  # Author:: Matthew Lipper
  module DPrecision

    def DPrecision.to_p(date,prec=DEFAULT)

      case prec
        when MIN then PDate.min(*DPrecision.explode(date,prec))
        when DAY then PDate.day(*DPrecision.explode(date,prec))
        when HOUR then PDate.hour(*DPrecision.explode(date,prec))
        when WEEK then PDate.week(*DPrecision.explode(date,prec))
        when MONTH then PDate.month(*DPrecision.explode(date,prec))
        when YEAR then PDate.year(*DPrecision.explode(date,prec))
        when SEC then PDate.sec(*DPrecision.explode(date,prec))
        when MILLI then date #raise "Not implemented."
        else PDate.default(*DPrecision.explode(date,prec))
      end
    end

    def DPrecision.explode(date,prec)
      result = [date.year,date.month,date.day]
        if(date.respond_to?("hour"))
          result << date.hour << date.min << date.sec
        else
          result << 0 << 0 << 0
        end
      result
    end

    #Simple value class for keeping track of precisioned dates
    class Precision
      include Comparable

      attr_reader :precision
      private_class_method :new

      #Some constants w/arbitrary integer values used internally for comparisions
      YEAR_PREC = 0
      MONTH_PREC = 1
      WEEK_PREC = 2
      DAY_PREC = 3
      HOUR_PREC = 4
      MIN_PREC = 5
      SEC_PREC = 6
      MILLI_PREC = 7

      #String values for display
      LABEL = { YEAR_PREC => "YEAR",
        MONTH_PREC => "MONTH",
        WEEK_PREC => "WEEK",
        DAY_PREC => "DAY",
        HOUR_PREC => "HOUR",
        MIN_PREC => "MINUTE",
        SEC_PREC => "SECOND",
        MILLI_PREC => "MILLISECOND"}

      #Minimun values that precisioned fields get set to
      FIELD_MIN = { YEAR_PREC => 1,
      MONTH_PREC => 1,
      WEEK_PREC => 1,
      DAY_PREC => 1,
      HOUR_PREC => 0,
      MIN_PREC => 0,
      SEC_PREC => 0,
      MILLI_PREC => 0}

      def Precision.year
        new(YEAR_PREC)
      end

      def Precision.month
        new(MONTH_PREC)
      end

      def Precision.week
        new(WEEK_PREC)
      end 
      
      def Precision.day
        new(DAY_PREC)
      end

      def Precision.hour
        new(HOUR_PREC)
      end

      def Precision.min
        new(MIN_PREC)
      end

      def Precision.sec
        new(SEC_PREC)
      end

      def Precision.millisec
        new(MILLI_PREC)
      end

      def min_value()
        FIELD_MIN[@precision]
      end

      def initialize(prec)
        @precision = prec
      end

      def <=>(other)
        self.precision <=> other.precision
      end

      def ===(other)
        self.precision == other.precision
      end

      def to_s
        "DPrecision::#{self.label}"
      end

      def label
        LABEL[@precision]
      end
  end

  #Pseudo Singletons:
  YEAR = Precision.year
  MONTH = Precision.month
  WEEK = Precision.week
  DAY = Precision.day
  HOUR = Precision.hour
  MIN = Precision.min
  SEC = Precision.sec
  MILLI = Precision.millisec
  DEFAULT=MIN

  end

end
