#!/usr/bin/env ruby

require 'baseexpressiontest'

class WeekIntervalTest < BaseExpressionTest

  def test_every_other_week
	expr = WeekInterval.new(Date.new(2013,4,23),2)
	good_dates = [Date.new(2013,4,21), Date.new(2013,4,27),Date.new(2013,5,8)]
    good_dates.each do |date|
	  assert(expr.include?(date),"Expr<#{expr}> should include #{date.ctime}")
	end
	bad_dates = [Date.new(2013,4,20), Date.new(2013,4,28)]
    bad_dates.each do |date|
	  assert(!expr.include?(date),"Expr<#{expr}> should not include #{date.ctime}")
	end
  end

  def test_every_third_week_spans_a_year
	expr = WeekInterval.new(Date.new(2013,12,25),3)
	good_dates = [Date.new(2013,12,22),Date.new(2014,1,12)]
    good_dates.each do |date|
	  assert(expr.include?(date),"Expr<#{expr}> should include #{date.ctime}")
	end
	bad_dates = [Date.new(2013,12,21), Date.new(2013,12,31),Date.new(2014,01,11),Date.new(2014,01,19)]
    bad_dates.each do |date|
	  assert(!expr.include?(date),"Expr<#{expr}> should not include #{date.ctime}")
	end
  end

  def test_biweekly_with_sunday_start_with_diweek
    every_other_friday = WeekInterval.new(Date.new(2006,2,26), 2) & DIWeek.new(Friday)

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

  def test_biweekly_with_friday_start_with_diweek
    every_other_wednesday = WeekInterval.new(Date.new(2006,3,3), 2) & DIWeek.new(Wednesday)

    # should match the First friday and every other Friday after that
    good_dates = [Date.new(2006,3,1), Date.new(2006,3,15), Date.new(2006,3,29)]
    bad_dates = [Date.new(2006,3,2), Date.new(2006,3,8), Date.new(2006,3,22)]

    good_dates.each do |date|
      assert every_other_wednesday.include?(date), "Expression #{every_other_wednesday.to_s} should include #{date}"
    end

    bad_dates.each do |date|
      assert !every_other_wednesday.include?(date), "Expression #{every_other_wednesday.to_s} should not include #{date}"
    end
  end

  def test_tue_thur_every_third_week_with_diweek
    every_tth_every_3 = WeekInterval.new(Date.new(2006,5,1), 3) & (DIWeek.new(Tuesday) | DIWeek.new(Thursday))

    # should match the First tuesday and thursday for week 1 and every 3 weeks thereafter
    good_dates = [Date.new(2006,5,2), Date.new(2006,5,4), Date.new(2006,5,23), Date.new(2006,5,25), Date.new(2006,6,13), Date.new(2006,6,15)]
    bad_dates = [Date.new(2006,5,3), Date.new(2006,5,9), Date.new(2006,5,18)]

    good_dates.each do |date|
      assert every_tth_every_3.include?(date), "Expression #{every_tth_every_3.to_s} should include #{date}"
    end

    bad_dates.each do |date|
      assert !every_tth_every_3.include?(date), "Expression #{every_tth_every_3.to_s} should not include #{date}"
    end

    range_start = Date.new(2006,5,1)
    range_end = Date.new(2006,8,1)
    expected_dates = [
      Date.new(2006,5,2), Date.new(2006,5,4),
      Date.new(2006,5,23), Date.new(2006,5,25),
      Date.new(2006,6,13), Date.new(2006,6,15),
      Date.new(2006,7,4), Date.new(2006,7,6),
      Date.new(2006,7,25), Date.new(2006,7,27)
    ]

    dates = every_tth_every_3.dates(DateRange.new(range_start, range_end))
    assert_equal dates, expected_dates
  end

  def test_to_s
    date = Date.new(2006,2,26)
    assert_equal "every 2nd week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 2).to_s
    assert_equal "every 3rd week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 3).to_s
    assert_equal "every 4th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 4).to_s
    assert_equal "every 5th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 5).to_s
    assert_equal "every 6th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 6).to_s
    assert_equal "every 7th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 7).to_s
    assert_equal "every 8th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 8).to_s
    assert_equal "every 9th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 9).to_s
    assert_equal "every 10th week starting with the week containing #{Runt.format_date(date)}", WeekInterval.new(date, 10).to_s
  end


end
