#!/usr/bin/env ruby

$:<<'../lib'

require 'test/unit'
require 'runt'
require 'date'

# Unit tests for DPrecision class
#
# Author:: Matthew Lipper
class DPrecisionTest < Test::Unit::TestCase

  include Runt

  def test_comparable
    assert(DPrecision::YEAR<DPrecision::MONTH, "DPrecision.year was not less than DPrecision.month")
    assert(DPrecision::MONTH<DPrecision::DAY, "DPrecision.month was not less than DPrecision.day")
    assert(DPrecision::DAY<DPrecision::HOUR, "DPrecision.day was not less than DPrecision.hour")
    assert(DPrecision::HOUR<DPrecision::MIN, "DPrecision.hour was not less than DPrecision.min")
    assert(DPrecision::MIN<DPrecision::SEC, "DPrecision.min was not less than DPrecision.sec")
    assert(DPrecision::SEC<DPrecision::MILLI, "DPrecision.sec was not less than DPrecision.millisec")
  end

  def test_pseudo_singleton_instance
    assert(DPrecision::YEAR.id==DPrecision::YEAR.id, "Object Id's not equal.")
    assert(DPrecision::MONTH.id==DPrecision::MONTH.id, "Object Id's not equal.")
    assert(DPrecision::DAY.id==DPrecision::DAY.id, "Object Id's not equal.")
    assert(DPrecision::HOUR.id==DPrecision::HOUR.id, "Object Id's not equal.")
    assert(DPrecision::MIN.id==DPrecision::MIN.id, "Object Id's not equal.")
    assert(DPrecision::SEC.id==DPrecision::SEC.id, "Object Id's not equal.")
    assert(DPrecision::MILLI.id==DPrecision::MILLI.id, "Object Id's not equal.")
  end

  def test_to_precision
    #February 29th, 2004
    no_prec_date = PDate.civil(2004,2,29)
    month_prec = PDate.month(2004,2,29)
    assert(month_prec==DPrecision.to_p(no_prec_date,DPrecision::MONTH))
    #11:59:59 am, February 29th, 2004
    no_prec_datetime = PDate.civil(2004,2,29,23,59,59)
    #puts "-->#{no_prec_datetime.date_precision}<--"
    assert(month_prec==DPrecision.to_p(no_prec_datetime,DPrecision::MONTH))
  end

end
