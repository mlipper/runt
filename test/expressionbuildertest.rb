#!/usr/bin/env ruby

require 'minitest_helper'

class ExpressionBuilderTest < MiniTest::Unit::TestCase

  def setup
    @builder = ExpressionBuilder.new
  end

  def test_define_should_instance_eval_a_block
    @builder.define do
      @ctx = "meow"
    end
    assert_equal "meow", @builder.ctx, "Expected instance variable @ctx to be set by block"  
  end
  
  def test_add_should_initialize_empty_ctx_with_expression
    result = @builder.add('expr',:to_s)
    assert_equal 'expr', result, "Result should equal string given to add method"
    assert_equal 'expr', @builder.ctx, "Builder context should equal result"
  end

  def test_add_should_send_op_to_ctx_with_expression
    @builder.add('abc',:to_s)
    result = @builder.add('def',:concat)
    assert_equal 'abcdef', result, "Result should equal concatenated strings given to add method"
    assert_equal 'abcdef', @builder.ctx, "Builder context should equal result"
  end

  def test_on_should_call_add_with_expression_and_ampersand
    @builder.add(1,:to_s)
    result = @builder.on(3) # result = 1 & 3
    assert_equal 1, result, "Result should equal 1 == 1 & 3"
    assert_equal 1, @builder.ctx, "Builder context should equal result"
  end

  def test_except_should_call_add_with_expression_and_minus
    @builder.add(1,:to_s)
    result = @builder.except(3) # result = 1 - 3
    assert_equal -2, result, "Result should equal -2 == 1 - 3"
    assert_equal -2, @builder.ctx, "Builder context should equal result"
  end

  def test_possibly_should_call_add_with_expression_and_pipe
    @builder.add(1, :to_s)
    result = @builder.possibly(2) # result = 1 | 2
    assert_equal 3, result, "Result should equal 3 == 1 | 2"
    assert_equal 3, @builder.ctx, "Builder context should equal result"
  end
  
  def test_builder_created_expression_should_equal_manually_created_expression
    manual = Runt::REDay.new(8,45,9,30) & Runt::DIWeek.new(Runt::Friday) | \
      Runt::DIWeek.new(Runt::Saturday) -  Runt::DIMonth.new(Runt::Last, Runt::Friday)
    expression = @builder.define do
      on daily_8_45am_to_9_30am
      on friday
      possibly saturday
      except last_friday
    end
    assert_equal manual.to_s, expression.to_s, "Expected #{manual.to_s} but was #{expression.to_s}"
  end
end
