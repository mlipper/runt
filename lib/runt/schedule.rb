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
    #  NOTE: version 0.5.0 no longer uses an Array of ScheduleElements 
    #  internally to hold data. This would only matter to clients if they
    #  they depended on the ability to call add multiple times for the same
    #  event. Use the update method instead.
    def add(event, expression)
      @elems[event]=expression
    end

    # For the given date range, returns an Array of PDate objects at which
    # the supplied event is scheduled to occur.
    def dates(event, date_range)
      result=[]
      date_range.each do |date|
        result.push date if include?(event,date)
      end
      result
    end
    
    def scheduled_dates(date_range)
      @elems.values.collect{|expr| expr.dates(date_range)}.flatten.sort.uniq
    end

    # Return true or false depend on if the supplied event is scheduled to occur on the
    # given date.
    def include?(event, date)
      return false unless @elems.include?(event)
      return 0<(self.select{|ev,xpr| ev.eql?(event)&&xpr.include?(date);}).size
    end

    #
    # Returns all Events whose Temporal Expression includes the given date/expression
    #
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

    #
    # Call the supplied block/Proc with the currently configured 
    # TemporalExpression associated with the supplied Event.
    #
    def update(event,&block)
      block.call(@elems[event])
    end

    def date_to_event_hash(event_attribute=:id)
      start_date = end_date = nil
      @elems.keys.each do |event|
        start_date = event.start_date if start_date.nil? || start_date > event.start_date
        end_date = event.end_date if end_date.nil? || end_date < event.end_date
      end
      
      scheduled_dates(DateRange.new(start_date, end_date)).inject({}) do |h, date|
        h[date] = events(date).collect{|e| e.send(event_attribute)}
        h
      end
    end
  end
  
  # TODO: Extend event to take other attributes

  class Event

    attr_reader :id

    def initialize(id)
      raise Exception, "id argument cannot be nil" unless !id.nil?
      @id=id
    end

    def to_s; @id.to_s end

    def == (other)
      return true if other.kind_of?(Event) && @id==other.id
    end

  end

end
