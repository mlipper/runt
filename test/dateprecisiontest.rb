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
    assert(DPrecision::MONTH<DPrecision::DAY_OF_MONTH, "DPrecision.month was not less than DPrecision.day_of_month")
    assert(DPrecision::DAY_OF_MONTH<DPrecision::HOUR_OF_DAY, "DPrecision.day_of_month was not less than DPrecision.hour_of_day")
    assert(DPrecision::HOUR_OF_DAY<DPrecision::MINUTE, "DPrecision.hour_of_day was not less than DPrecision.minute")
    assert(DPrecision::MINUTE<DPrecision::SECOND, "DPrecision.minute was not less than DPrecision.second")
    assert(DPrecision::SECOND<DPrecision::MILLISECOND, "DPrecision.second was not less than DPrecision.millisecond")
  end

  def test_pseudo_singleton_instance
    assert(DPrecision::YEAR.id==DPrecision::YEAR.id, "Object Id's not equal.")
    assert(DPrecision::MONTH.id==DPrecision::MONTH.id, "Object Id's not equal.")
    assert(DPrecision::DAY_OF_MONTH.id==DPrecision::DAY_OF_MONTH.id, "Object Id's not equal.")
    assert(DPrecision::HOUR_OF_DAY.id==DPrecision::HOUR_OF_DAY.id, "Object Id's not equal.")
    assert(DPrecision::MINUTE.id==DPrecision::MINUTE.id, "Object Id's not equal.")
    assert(DPrecision::SECOND.id==DPrecision::SECOND.id, "Object Id's not equal.")
    assert(DPrecision::MILLISECOND.id==DPrecision::MILLISECOND.id, "Object Id's not equal.")
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
