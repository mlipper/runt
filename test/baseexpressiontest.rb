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
    @pdate_20060914 = PDate.new(2006,9,14)
    @pdate_20060921 = PDate.new(2006,9,21)
    @pdate_20071008 = PDate.new(2007,10,8)
    @pdate_20071028 = PDate.new(2007,10,28)
    @pdate_20071030 = PDate.new(2007,10,30)
    @pdate_20071114 = PDate.new(2007,11,14)
    @date_19611101 = Date.civil(1961,11,1)
    @date_20040806 = Date::new(2004,8,6)
  end

  def test_nothing
    # Sigh...I should figure out how to tell TestUnit that this is an "abstract" class
  end

end
