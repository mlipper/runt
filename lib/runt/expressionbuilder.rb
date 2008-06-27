#
# Convenience class for building temporal expressions in a more 
# human-friendly way. Used in conjunction with shortcuts defined in the 
# sugar.rb file, this allows one to create expressions like the following:
#   
#   b = ExpressionBuilder.new
#   expr = b.define do
#     occurs daily_8_30am_to_9_45am
#     on tuesday
#     possibly wednesday
#   end
#
# This equivalent to:
#
#   expr = REDay.new(8,30,9,45) & DIWeek.new(Tuesday) | DIWeek.new(Wednesday)
#
# ExpressionBuilder creates expressions by evaluating a block passed to the 
# :define method. From inside the block, methods :occurs, :on, :every, :possibly,
# and maybe can be called with a temporal expression which will be added to
# a composite expression as follows:
#
# * <b>:on</b> - creates an "and" (&)
# * <b>:possibly</b> - creates an "or" (|)  
# * <b>:except</b> - creates a "not" (-)
# * <b>:every</b> - alias for :on method
# * <b>:occurs</b> - alias for :on method
# * <b>:maybe</b> - alias for :possibly method 
#  
#
require 'runt'

class ExpressionBuilder

  include Runt

  attr_accessor :ctx

  def initialize
    @ctx = nil
  end

  def define(&block)
    instance_eval(&block)
  end
  
  def on(expr)
    add(expr, :&)
  end

  def add(expr, op)
    @ctx ||= expr
    @ctx = @ctx.send(op, expr) unless @ctx == expr
    @ctx # explicit return, previous line may not execute
  end

  def except(expr)
    add(expr, :-)
  end
  
  def possibly(expr)
    add(expr, :|)
  end

  alias_method :every, :on
  alias_method :occurs, :on
  alias_method :maybe, :possibly
end

if __FILE__ == $0
  builder = ExpressionBuilder.new
  expr = builder.define do
    occurs daily_11_00am_to_3_00pm
    on monday 
    possibly tuesday
    except last_monday
  end
  puts expr
end

