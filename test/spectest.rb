
#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for Spec class
# Author:: Matthew Lipper

class SpecTest < BaseExpressionTest

  def setup
    super
    @spec = Spec.new(@stub1)
  end

  def test_initialize
    assert_same @stub1, @spec.date_expr, "Expected #{@stub1}, instead got #{@spec.date_expr}"
  end

  def test_include_arg_has_include_method
    assert !@spec.include?(@stub2), "Expression should not include configured stub"
    @stub2.match = true
    assert @spec.include?(@stub2), "Expression should include configured stub"
  end

  def test_include_arg_without_include_method
    @spec = Spec.new(4)
    assert !@spec.include?(3), "Expression #{@spec.to_s} should not include 3"
    assert @spec.include?(4), "Expression #{@spec.to_s} should include 4"
  end 

  def test_to_s
    assert_equal @stub1.to_s, @spec.to_s
  end

end
