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

      if @elems.include?(event)
        @elems[event].push(ScheduleElement.new(event, expression))        
      else
        @elems[event] = [ScheduleElement.new(event, expression)]
      end

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
      result = Array.new
      @elems[event].each{|element| result << element.include?(event, date) }
      result.inject{|x,y| x && y}
    end

    private 
    def add_element
    end
  end

  private
  class ScheduleElement

    def initialize(event, expression)
      @event = event
      @expression = expression
    end

    def include?(event, date)
      return false unless @event == event
      @expression.include?(date)
    end
    
    def to_s
      "event: #{@event} expr: #{@expression}"
    end

  end

  public
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
