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
    @stub1 = StubExpression.new(false, "stub 1", false)
    @stub2 = StubExpression.new(false, "stub 2", false)
    @pdate_198606 = PDate.month(1986,6)                 # June, 1986
    @pdate_20040531 = PDate.day(2004,5,31)              # Monday, May 31st, 2004
    @pdate_20040704 = PDate.day(2004,7,4)               # Sunday, July 4th, 2004
    @pdate_20060914 = PDate.day(2006,9,14)              # Thursday, September 14th, 2006
    @pdate_20060921 = PDate.day(2006,9,21)              # Thursday, September 21st, 2006
    @pdate_20071008 = PDate.day(2007,10,8)              # Monday, October 8th, 2007
    @pdate_20071024 = PDate.day(2007,10,24)             # Wednesday, October 24th, 2007
    @pdate_20071028 = PDate.day(2007,10,28)             # Sunday, October 28th, 2007
    @pdate_20071030 = PDate.day(2007,10,30)             # Tuesday, October 30th, 2007
    @pdate_20071114 = PDate.day(2007,11,14)             # Wednesday, November 14th, 2007
    @pdate_1922041816 = PDate.hour(1922,4,18,16)        # 4pm, Tuesday, April 18th, 1922
    @pdate_1975060512 = PDate.hour(1975,6,5,12)         # 12pm, Thursday, June 5th, 1975
    @pdate_2004090600 = PDate.hour(2004,9,6,0)          # 12am, Monday, September 6th, 2004
    @pdate_2012050803 = PDate.hour(2012,5,8,3)          # 3am, Tuesday, May 8th, 2012
    @pdate_2012050815 = PDate.hour(2012,5,8,15)         # 3pm, Tuesday, May 8th, 2012
    @pdate_200401282100 = PDate.min(2004,01,28,21,00) 
    @pdate_200401280000 = PDate.min(2004,01,28,00,00)
    @pdate_200401280001 = PDate.min(2004,01,28,00,01)
    @pdate_200405010806 = PDate.min(2004,5,1,8,6)
    @pdate_200405030906 = PDate.min(2004,5,3,9,6)
    @pdate_200405040806 = PDate.min(2004,5,4,8,6)
    @pdate_200605291012 = PDate.min(2006,5,29,10,12)
    @pdate_200605301400 = PDate.min(2006,5,30,14,00)
    @pdate_200609211001 = PDate.min(2006,9,21,10,1)
    @pdate_200609211002 = PDate.min(2006,9,21,10,2)
    @pdate_20071116100030 = PDate.sec(2007,11,16,10,0,30)
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
    @datetime_200403081200 = DateTime.new(2004,3,8,12,0)   # 12:00pm, Monday, March 8th, 2004
    @datetime_200403100800 = DateTime.new(2004,3,10,8,00)
    @datetime_200403100915 = DateTime.new(2004,3,10,9,15)
    @datetime_200403101915 = DateTime.new(2004,3,10,19,15) # 7:15pm, Wednesday, March 10th, 2004
    @datetime_200403110000 = DateTime.new(2004,3,11,0,0)   # 12:00am, Thursday, March 11th, 2004
    @datetime_200403110115 = DateTime.new(2004,3,11,1,15)
    @datetime_200403111215 = DateTime.new(2004,3,11,12,15)
    @datetime_200403140900 = DateTime.new(2004,3,14,9,00)  # 9:00am, Sunday, March 14th, 2004
    @datetime_200709161007 = DateTime.new(2007,9,16,10,7)
    @time_20070925115959 = Time.mktime(2007,9,25,11,59,59) # 11:59:59am, Tuesday, September 25th, 2007
    @time_20070926000000 = Time.mktime(2007,9,26,0,0,0)    # 12:00:00am, Wednesday, September 26th, 2007
    @time_20070927065959 = Time.mktime(2007,9,27,6,59,59)  #  6:59:59am, Thursday, September 27th, 2007
    @time_20070927115900 = Time.mktime(2007,9,27,11,59,0)  # 11:59:00am, Thursday, September 27th, 2007
    @time_20070928000000 = Time.mktime(2007,9,28,0,0,0)    # 12:00:00am, Friday, September 28th, 2007
    @time_20070929110000 = Time.mktime(2007,9,29,11,0,0)   # 11:00:00am, Saturday, September 29th, 2007
    @time_20070929000000 = Time.mktime(2007,9,29,0,0,0)    # 12:00:00am, Saturday, September 29th, 2007
    @time_20070929235959 = Time.mktime(2007,9,29,23,59,59) # 11:59:59pm, Saturday, September 29th, 2007
    @time_20070930235959 = Time.mktime(2007,9,30,23,59,59) # 11:59:59am, Sunday, September 30th, 2007
  end

  def test_nothing
    # Sigh...I should figure out how to tell TestUnit that this is an "abstract" class
  end

end

class StubExpression
  include Runt
  include TExpr
  attr_accessor :match, :string, :overlap, :args
  def initialize(match=false, string="StubExpression",overlap=false)
    @match=match
    @string=string
    @overlap=overlap
    @args=[]
  end
  def include?(arg)
    @args << arg
    @match
  end
  def overlap?(arg)
    @args << arg
    @overlap
  end
  def to_s
    @string
  end
end
