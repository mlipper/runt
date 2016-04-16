#!/usr/bin/ruby

require 'test/unit'
require 'runt'
require 'payment_report'

class ReportTest < Test::Unit::TestCase

  include Runt

  def setup
    @schedule = Schedule.new

    # Gas payment on the first Wednesday of every month
    @gas_payment = Payment.new("Gas", 234)
    @gas_expr = DIMonth.new(First, Wednesday)
    @schedule.add(@gas_payment, @gas_expr)

    # Insurance payment every year on January 7th
    @insurance_payment = Payment.new("Insurance", 345)
    @insurance_expr = REYear.new(1, 7, 1, 7)
    @schedule.add(@insurance_payment, @insurance_expr)
    @report = Report.new(@schedule)
  end
  def test_initialize
    assert_equal @schedule, @report.schedule
  end
  def test_list
    range = PDate.day(2008, 1, 1)..PDate.day(2008,1,31)
    result = @report.list(range)
    assert_equal(2, result.size)
    assert_equal(@gas_payment, result[PDate.day(2008, 1, 2)][0])
    assert_equal(@insurance_payment, result[PDate.day(2008, 1, 7)][0])
  end
end

class PaymentTest < Test::Unit::TestCase

  include Runt

  def test_initialize
    p = Payment.new "Foo", 12
    assert_equal "Foo", p.id
    assert_equal 12, p.amount
  end

end


