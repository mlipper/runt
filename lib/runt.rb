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
module Runt
  VERSION_MAJOR = 0
  VERSION_MINOR = 1
  RELEASE = 0
  DEBUG = false
end

require "runt/dateprecision"
require "runt/temporalexpression"