#!/usr/bin/env ruby

module Runt


  # Implementation of a <tt>pattern</tt>[http://martinfowler.com/apsupp/recurring.pdf]
  # for recurring calendar events created by Martin Fowler.
  class Schedule

    def initialize
      @elements = Array.new
    end

    #  Schedule event to occur using the given expression.
    def add(event, expression)
      @elements.push(ScheduleElement.new(event, expression))
    end

    # For the given date range, returns an Array of TimePoint objects at which
    # the supplied event is scheduled to occur.
    def dates(event, date_range)
      result = Array.new
      date_range.each do |date|
        result.push date if is_occurring?(date)
      end
      result
    end

    # Return true or false depend on if the supplied event is scheduled to occur on the
    # given date.
    def is_occurring?(event, date)
      @elements.each{|element| element.is_occurring?(event, date) }
    end

  end

  private
  class ScheduleElement

    def initialize(event, expression)
      @event = event
      @expression = expression
    end

    def is_occurring?(event, date)
      return false unless @event == event
      @expression.include?(date)
    end
  end

  class Event

    attr_reader :schedule, :id

    def initialize(id,schedule=Schedule.new)
      raise Exception, "id argument cannot be nil" unless !id.nil?
      @id = id
      @schedule = schedule
    end

    #  Schedule this event to occur using the given expression.
    def add_schedule(expression)
      schedule.add(schedule.add(self, expression))
    end

    def to_s; @id.to_s end

    def == (other)
      return true if other.kind_of?(Event) && @id == other.id
    end
  end


end
