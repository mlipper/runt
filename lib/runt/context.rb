#!/usr/bin/env ruby

require 'date'
require 'runt/dprecision'
require 'runt/pdate'

#
# Author:: Matthew Lipper

module Runt

class Context

  attr_accessor :stack
  
  def initialize
    @stack = Array.new
  end
  
  def push(expr)
    @stack.push expr
  end

  def pop
    @stack.pop
  end

end

end
