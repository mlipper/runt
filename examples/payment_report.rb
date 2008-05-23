#!/usr/bin/ruby

require 'runt'

class Report
  
  attr_reader :schedule

  def initialize(schedule)
    @schedule = schedule
  end
  def list(range)
    result = {}
    range.each do |dt|
      events = @schedule.events(dt)
      result[dt]=events unless events.empty?
    end
    result
  end
end

class Payment < Runt::Event
  attr_accessor :amount
  def initialize(id, amount)
    super(id)
    @amount = amount
  end
end


if __FILE__ == $0

  include Runt

  schedule = Schedule.new

  # Gas payment on the first Wednesday of every month
  gas_payment = Payment.new("Gas", 234)
  gas_expr = DIMonth.new(First, Wednesday)
  schedule.add(gas_payment, gas_expr)

  # Insurance payment every year on January 7th
  insurance_payment = Payment.new("Insurance", 345)
  insurance_expr = REYear.new(1, 7, 1, 7)
  schedule.add(insurance_payment, insurance_expr)
  
  # Run a report
  report = Report.new(schedule)
  result = report.list(PDate.day(2008, 1, 1)..PDate.day(2008,1,31))
  result.keys.sort.each do |dt|
    unless result[dt].empty? then
      print "#{dt.ctime} - "
      result[dt].each do |event|
	puts "#{event.id}, $#{event.amount}"
      end
    end
  end

end
