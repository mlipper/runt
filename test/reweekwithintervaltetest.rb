#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for WeekIntervalTE class
# Author:: Jeff Whitmire

class REWeekWithIntervalTETest < BaseExpressionTest
  
  def test_biweekly_with_sunday_start
    every_other_friday = REWeekWithIntervalTE.new(Date.new(2006,2,26), 2, 5)
    
    # should match the First friday and every other Friday after that
    good_dates = [Date.new(2006,3,3), Date.new(2006,3,17), Date.new(2006,3,31)]
    bad_dates = [Date.new(2006,3,1), Date.new(2006,3,10), Date.new(2006,3,24)]
    
    good_dates.each do |date|
      assert every_other_friday.include?(date), "Expression #{every_other_friday.to_s} should include #{date}"
    end
    
    bad_dates.each do |date|
      assert !every_other_friday.include?(date), "Expression #{every_other_friday.to_s} should not include #{date}"
    end
  end

  def test_biweekly_with_friday_start
    every_other_friday = REWeekWithIntervalTE.new(Date.new(2006,3,3), 2, 3)
    
    # should match the First friday and every other Friday after that
    good_dates = [Date.new(2006,3,1), Date.new(2006,3,15), Date.new(2006,3,29)]
    bad_dates = [Date.new(2006,3,2), Date.new(2006,3,8), Date.new(2006,3,22)]
    
    good_dates.each do |date|
      assert every_other_friday.include?(date), "Expression #{every_other_friday.to_s} should include #{date}"
    end
    
    bad_dates.each do |date|
      assert !every_other_friday.include?(date), "Expression #{every_other_friday.to_s} should not include #{date}"
    end
  end

  def test_tue_thur_every_third_week
    every_tth_every_3 = REWeekWithIntervalTE.new(Date.new(2006,5,1), 3, [2, 4])
    
    # should match the First tuesday and thursday for week 1 and every 3 weeks thereafter
    good_dates = [Date.new(2006,5,2), Date.new(2006,5,4), Date.new(2006,5,23), Date.new(2006,5,25), Date.new(2006,6,13), Date.new(2006,6,15)]
    bad_dates = [Date.new(2006,5,3), Date.new(2006,5,9), Date.new(2006,5,18)]
    
    good_dates.each do |date|
      assert every_tth_every_3.include?(date), "Expression #{every_tth_every_3.to_s} should include #{date}"
    end
    
    bad_dates.each do |date|
      assert !every_tth_every_3.include?(date), "Expression #{every_tth_every_3.to_s} should not include #{date}"
    end
  end

  def test_to_s
    date = Date.new(2006,2,26)
    assert_equal "every 2nd week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 2, [2,4]).to_s
    assert_equal "every 3rd week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 3, [2,4]).to_s
    assert_equal "every 4th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 4, [2,4]).to_s
    assert_equal "every 5th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 5, [2,4]).to_s
    assert_equal "every 6th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 6, [2,4]).to_s
    assert_equal "every 7th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 7, [2,4]).to_s
    assert_equal "every 8th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 8, [2,4]).to_s
    assert_equal "every 9th week after #{Runt.format_date(date)}",  REWeekWithIntervalTE.new(date, 9, [2,4]).to_s
    assert_equal "every 10th week after #{Runt.format_date(date)}", REWeekWithIntervalTE.new(date, 10, [2,4]).to_s
  end

  def test_validate_interval
    assert_raise_message ArgumentError, "interval is required" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), nil, [2,4])
    end
    assert_raise_message ArgumentError, "interval must be in the range (2..10)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), -1, [2,4])
    end
    assert_raise_message ArgumentError, "interval must be in the range (2..10)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 0, [2,4])
    end
    assert_raise_message ArgumentError, "interval must be in the range (2..10)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 1, [2,4])
    end
    assert_raise_message ArgumentError, "interval must be in the range (2..10)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 11, [2,4])
    end
    assert_nothing_raised do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 2, [2,4])
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 5, [2,4])
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 10, [2,4])
    end
  end

  def test_validate_week_days
    assert_raise_message ArgumentError, "weekdays are required" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, nil)
    end
    assert_raise_message ArgumentError, "weekdays are required" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, [])
    end
    assert_raise_message ArgumentError, "weekdays must be in the range (0..6)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, 8)
    end
    assert_raise_message ArgumentError, "weekdays must be in the range (0..6)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, [1,3,9])
    end
    assert_raise_message ArgumentError, "weekdays must be in the range (0..6)" do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, [1,-3])
    end
    assert_nothing_raised do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, 5)
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, [2,4])
    end
  end

  def test_validate_base_date
    assert_raise_message ArgumentError, "starting date is required" do
      REWeekWithIntervalTE.new(nil, 3, [2,4])
    end
    assert_raise_message ArgumentError, "starting date must be a valid date" do
      REWeekWithIntervalTE.new(4, 3, [2,4])
    end
    assert_nothing_raised do
      REWeekWithIntervalTE.new(Date.new(2006,2,26), 3, [2,4])
    end
  end
end
