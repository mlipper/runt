#!/usr/bin/env ruby

module Runt


  # Implementation of a <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
  # for recurring calendar events created by Martin Fowler.
  class Schedule

    def initialize
      @elems = Hash.new
      self
    end

    #  Schedule event to occur using the given expression.
    def add(event, expression)
      @elems[event]=expression
    end

    # For the given date range, returns an Array of PDate objects at which
    # the supplied event is scheduled to occur.
    def dates(event, date_range)
      result = Array.new
      date_range.each do |date|
        result.push date if include?(event,date)
      end
      result
    end

    # Return true or false depend on if the supplied event is scheduled to occur on the
    # given date.
    def include?(event, date)
      return false unless @elems.include?(event)
      return 0<(self.select{|ev,xpr| ev.eql?(event)&&xpr.include?(date);}).size
    end

    def events(date)
      self.select{|ev,xpr| xpr.include?(date);}
    end

    #
    # Selects events using the user supplied block/Proc. The Proc must accept 
    # two parameters: an Event and a TemporalExpression. It will be called 
    # with each existing Event-expression pair at which point it can choose
    # to include the Event in the final result by returning true or to filter 
    # it by returning false.
    #
    def select(&block)
      result=[]
      @elems.each_pair{|event,xpr| result.push(event) if block.call(event,xpr);}
      result
    end

  end

  class Event

    attr_reader :schedule, :id

    def initialize(id)
      raise Exception, "id argument cannot be nil" unless !id.nil?
      @id = id
    end

    def to_s; @id.to_s end

    def == (other)
      return true if other.kind_of?(Event) && @id == other.id
    end

  end

end
