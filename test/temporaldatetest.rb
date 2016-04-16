
#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for TemporalDate class
# Author:: Matthew Lipper

class TemporalDateTest < BaseExpressionTest

  def setup
    super
    @spec = TemporalDate.new(@stub1)
  end

  def test_initialize
    assert_same @stub1, @spec.date_expr, "Expected #{@stub1}, instead got #{@spec.date_expr}"
  end

  def test_specific_date
    date_spec = TemporalDate.new(Date.new(2006,06,27))

    assert !date_spec.include?(Date.new(2005,06,27))
    assert !date_spec.include?(Date.new(2006,06,26))
    assert date_spec.include?(Date.new(2006,06,27))
    assert !date_spec.include?(Date.new(2006,06,28))
    assert !date_spec.include?(Date.new(2007,06,27))
  end

  def test_include_arg_has_include_method
    assert !@spec.include?(@stub2), "Expression should not include configured stub"
    @stub2.match = true
    assert @spec.include?(@stub2), "Expression should include configured stub"
  end

  def test_include_arg_without_include_method
    @spec = TemporalDate.new(4)
    assert !@spec.include?(3), "Expression #{@spec.to_s} should not include 3"
    assert @spec.include?(4), "Expression #{@spec.to_s} should include 4"
  end

  def test_to_s
    assert_equal @stub1.to_s, @spec.to_s
  end

end
