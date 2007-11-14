#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'time'

$DEBUG=false

# Base test case for refactored temporal expression unit tests
# Author:: Matthew Lipper

class BaseExpressionTest < Test::Unit::TestCase

  include Runt
  include DPrecision

  def setup
    @pdate_198606 = PDate::month(1986,6)
    @pdate_20060914 = PDate.day(2006,9,14)
    @pdate_20060921 = PDate.day(2006,9,21)
    @pdate_20071008 = PDate.day(2007,10,8)
    @pdate_20071024 = PDate.day(2007,10,24)
    @pdate_20071028 = PDate.day(2007,10,28)
    @pdate_20071030 = PDate.day(2007,10,30)
    @pdate_20071114 = PDate.day(2007,11,14)
    @date_19611101 = Date.civil(1961,11,1)
    @date_20040109 = Date.civil(2004,1,9)   # Friday, January 9th 2004
    @date_20040116 = Date.civil(2004,1,16)  # Friday, January 16th 2004
    @date_20040125 = Date.civil(2004,1,25)  # Sunday, January 25th 2004
    @date_20040501 = Date.civil(2004,5,1)
    @date_20040806 = Date.civil(2004,8,6)
    @date_20050101 = Date.civil(2005,1,1)
    @date_20050102 = Date.civil(2005,1,2)
    @date_20050109 = Date.civil(2005,1,9)
    @date_20050116 = Date.civil(2005,1,16)
    @date_20050123 = Date.civil(2005,1,23)
    @date_20050130 = Date.civil(2005,1,30)
    @date_20050131 = Date.civil(2005,1,31)
    @date_20050228 = Date.civil(2005,2,28)
    @date_20051231 = Date.civil(2005,12,31)
    @date_20060504 = Date.civil(2006,5,4)
  end

  def test_nothing
    # Sigh...I should figure out how to tell TestUnit that this is an "abstract" class
  end

end
