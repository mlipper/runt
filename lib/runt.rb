# License: see LICENSE.txt
#  Runt - Ruby Temporal Expressions 
#
#	
#  Copyright (C) 2004  Matthew Lipper <info@digitalclash.com.com>
# 

##
# The Runt module is the main namespace for all Runt modules
# and classes.
#

require 'date'

module Runt
  VERSION_MAJOR = 0
  VERSION_MINOR = 1
  RELEASE = 0
  DEBUG = true
	
	include Tracing if $DEBUG 

	#See Date::ABBR_DAYNAMES
	Sunday = Date::DAYNAMES.index("Sunday")
	Monday = Date::DAYNAMES.index("Monday")
	Tuesday = Date::DAYNAMES.index("Tuesday")
	Wednesday = Date::DAYNAMES.index("Wednesday")
	Thursday = Date::DAYNAMES.index("Thursday")
	Friday = Date::DAYNAMES.index("Friday")
	Saturday = Date::DAYNAMES.index("Saturday")
	#See Date::ABBR_DAYNAMES
	Sun = Date::ABBR_DAYNAMES.index("Sun")
	Mon = Date::ABBR_DAYNAMES.index("Mon")
	Tue = Date::ABBR_DAYNAMES.index("Tue")
	Wed = Date::ABBR_DAYNAMES.index("Wed")
	Thu = Date::ABBR_DAYNAMES.index("Thu")
	Fri = Date::ABBR_DAYNAMES.index("Fri")
	Sat = Date::ABBR_DAYNAMES.index("Sat")

	First = 1
	Second = 2
	Third = 3
	Fourth = 4
	Fifth = 5
	Sixth = 6
	Seventh = 7
	Eigth = 8
	Ninth = 9
	Tenth = 10
	
	class ApplyLast
		def initialize()
			@negate=Proc.new{|n| n*-1}
		end
		def [](arg)
			@negate.call(arg)
		end
	end
	
	Last = ApplyLast.new
	Last_of = Last[First]
end

require "runt/dateprecision"
require "runt/timepoint"
require "runt/temporalexpression"