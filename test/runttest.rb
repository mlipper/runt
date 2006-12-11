#!/usr/bin/env ruby

require 'test/unit'
require 'runt'
require 'date'
require 'pp'

class RuntModuleTest < Test::Unit::TestCase
  
  def test_last
    assert Runt::Last == -1
  end
  
  def test_last_of
    assert Runt::Last_of == -1
  end

  def test_second_to_last
    assert Runt::Second_to_last == -2
  end

  def test_ordinals
    #1.upto(31){ |n| puts Runt.ordinalize(n); }
    assert_equal '1st', Runt.ordinalize(1)
    assert_equal '33rd', Runt.ordinalize(33)
    assert_equal '50th', Runt.ordinalize(50)
    assert_equal '2nd', Runt.ordinalize(2)
    assert_equal 'second to last', Runt.ordinalize(-2)
    assert_equal 'last', Runt.ordinalize(-1)
  end

  def test_day_name
    i=0
    Date::DAYNAMES.each do |n|
      assert_equal Date::DAYNAMES[i], Runt.day_name(i)
      i=i+1
    end
  end
  
  def test_month_name
    i=0
    Date::MONTHNAMES.each do |n|
      assert_equal Date::MONTHNAMES[i], Runt.month_name(i)
      i=i+1
    end
  end

  def test_strftime
    d=DateTime.new(2006,2,26,14,45)
    assert_equal '02:45PM', Runt.format_time(d)
  end

  def test_numeric_class_additions
    assert_equal 0.000001, 1.microsecond
    assert_equal 0.000001, 1.microseconds
    assert_equal 0.001, 1.millisecond
    assert_equal 0.001, 1.milliseconds
    assert_equal 7, 7.second
    assert_equal 7, 7.seconds
    assert_equal 60, 1.minute
    assert_equal 60, 1.minutes
    assert_equal 3600, 1.hour
    assert_equal 3600, 1.hours
    assert_equal 86400, 1.day
    assert_equal 86400, 1.days
    assert_equal 604800, 1.week
    assert_equal 604800, 1.weeks
    assert_equal 2592000, 1.month
    assert_equal 2592000, 1.months
    assert_equal 31536000, 1.year
    assert_equal 31536000, 1.years
    assert_equal 315360000, 1.decade
    assert_equal 315360000, 1.decades
  end

  def test_time_class_dprecision
    time=Time.parse('Monday 06 November 2006 07:38')
    assert_equal(Runt::DPrecision::DEFAULT,time.date_precision)
  end

  def test_date_class_dprecision
    date=Date.today
    assert_equal(Runt::DPrecision::DEFAULT,date.date_precision)
  end

  def test_datetime_class_dprecision
    date=DateTime.civil
    assert_equal(Runt::DPrecision::DEFAULT,date.date_precision)
  end

  def test_time_plus
    time=Time.parse("Sat Dec 09 05:56:12 -0500 2006")
    # Default precision is minute
    assert_equal(Runt::PDate.min(2006,12,9,5,56),Runt::DPrecision.to_p(time))
    assert_not_equal(Time.parse("Sat Dec 09 05:56:00 -0500 2006"),time)



  end

end
