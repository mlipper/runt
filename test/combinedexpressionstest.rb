
#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for composite temporal expressions
# Author:: Matthew Lipper

class CombinedExpressionTest < BaseExpressionTest

  def test_difference_te
    # Should match for 9am to 5pm except for 12pm to 1pm
    expr = REDay.new(9,0,17,0) - REDay.new(12,0,13,0)
    assert expr.include?(@pdate_200405030906), "Expression #{expr.to_s} should include #{@pdate_200405030906.to_s}"
    assert !expr.include?(@pdate_1975060512), "Expression #{expr.to_s} should not include #{@pdate_1975060512.to_s}"
  end

  def test_monday_tuesday_8am_to_9am
    expr = REWeek.new(Mon,Fri) & REDay.new(8,0,9,0)
    assert expr.include?(@pdate_200405040806), "Expression #{expr.to_s} should include #{@pdate_200405040806.to_s}"
    assert !expr.include?(@pdate_200405010806), "Expression #{expr.to_s} should not include #{@pdate_200405010806.to_s}"
    assert !expr.include?(@pdate_200405030906), "Expression #{expr.to_s} should not include #{@pdate_200405030906.to_s}"
  end
  

  def test_midnight_to_9am_or_tuesday
    expr = REDay.new(0,0,9,0) | DIWeek.new(Tuesday)
    assert expr.include?(@pdate_20071030), "Expression #{expr.to_s} should include #{@pdate_20071030.to_s}"
    assert expr.include?(@pdate_2012050803), "Expression #{expr.to_s} should include #{@pdate_2012050803.to_s}"
    assert !expr.include?(@pdate_20071116100030), "Expression #{expr.to_s} should not include #{@pdate_20071116100030.to_s}"
  end

  def test_wednesday_thru_saturday_6_to_12am
    expr = REWeek.new(Wed, Sat) & REDay.new(6,0,12,00)
    assert !expr.include?(@time_20070926000000), "Expression #{expr.to_s} should include #{@time_20070926000000.to_s}"
    assert expr.include?(@time_20070927065959), "Expression #{expr.to_s} should include #{@time_20070927065959.to_s}"
    assert !expr.include?(@time_20070928000000), "Expression #{expr.to_s} should include #{@time_20070928000000.to_s}"
    assert expr.include?(@time_20070929110000), "Expression #{expr.to_s} should include #{@time_20070929110000.to_s}"
  end

  def test_memorial_day
    # Monday through Friday, from 9am to 5pm
    job = REWeek.new(Mon,Fri) & REDay.new(9,00,17,00)
    # Memorial Day (U.S.)
    memorial_day = REYear.new(5) & DIMonth.new(Last,Monday)
    # May 29th, 2006
    last_monday_in_may = @pdate_200605291012
    # Before 
    assert job.include?(last_monday_in_may), "Expression #{job.to_s} should include #{last_monday_in_may.to_s}"
    assert job.include?(@pdate_200605301400), "Expression #{job.to_s} should include #{@pdate_200605301400.to_s}"
    # Add Diff expression
    job_with_holiday = job - last_monday_in_may
    assert !job_with_holiday.include?(last_monday_in_may), "Expression #{job_with_holiday.to_s} should not include #{last_monday_in_may.to_s}"
    # Still have to work on Tuesday
    assert job.include?(@pdate_200605301400), "Expression #{job.to_s} should include #{@pdate_200605301400.to_s}"
  end
  
  def test_summertime
    #This is a hack.....
    #In the U.S., Memorial Day begins the last Monday of May
    #
    #The month of May
    may=REYear.new(5)
    #Monday through Saturday
    monday_to_saturday = REWeek.new(1,6)
    #Last week of (any) month
    last_week_in = WIMonth.new(Last_of)
    #So, to say 'starting from the last Monday in May',
    #we need to select just that last week of May begining with
    #the Monday of that week
    last_week_of_may = may & monday_to_saturday & last_week_in

    #This is another hack similar to the above, except instead of selecting a range
    #starting at the begining of the month, we need to select only the time period in
    #September up until Labor Day.
    #
    #In the U.S., Labor Day is the first Monday in September
    #
    #The month of September
    september=REYear.new(9)
    #First week of (any) month
    first_week_in = WIMonth.new(First)
    entire_first_week_of_september = september & first_week_in
    #To exclude everything in the first week which occurs on or after Monday.
    first_week_of_september=entire_first_week_of_september - monday_to_saturday
    #June through August
    june_through_august=REYear.new(6, 1, 8)
    assert june_through_august.include?(@pdate_20040704), "Expression #{june_through_august.to_s} should include #{@pdate_20040704.to_s}"
    #Finally!
    summer_time = last_week_of_may | first_week_of_september | june_through_august

    #Will work, but will be incredibly slow:
    #  assert(summer_time.include?(PDate.min(2004,5,31,0,0)))
    assert summer_time.include?(@pdate_20040531), "Expression #{summer_time.to_s} should include #{@pdate_20040704.to_s}"
    assert summer_time.include?(@pdate_20040704), "Expression #{summer_time.to_s} should include #{@pdate_20040704.to_s}"
    #also works...also slow:
    #  assert(!summer_time.include?(PDate.min(2004,9,6,0,0)))
    assert !summer_time.include?(@pdate_2004090600), "Expression #{summer_time.to_s} should not include #{@pdate_2004090600.to_s}"

  end
  def test_nyc_parking_te

    #Monday, Wednesday, Friday
    mon_wed_fri = DIWeek.new(Mon) | \
                    DIWeek.new(Wed) | \
                      DIWeek.new(Fri)

    assert mon_wed_fri.include?(@datetime_200403101915), "Expression #{mon_wed_fri.to_s} should include #{@datetime_200403101915.to_s}"
    assert !mon_wed_fri.include?(@datetime_200403140900), "Expression #{mon_wed_fri.to_s} should not include #{@datetime_200403140900.to_s}"
    # 8am to 11am
    eight_to_eleven = REDay.new(8,00,11,00)
    # => Mon,Wed,Fri - 8am to 11am
    expr1 = mon_wed_fri & eight_to_eleven
    # Tuesdays, Thursdays
    tues_thurs = DIWeek.new(Tue) | DIWeek.new(Thu)
    # 11:30am to 2pm
    eleven_thirty_to_two = REDay.new(11,30,14,00)
    assert eleven_thirty_to_two.include?(@datetime_200403081200), "Expression #{eleven_thirty_to_two.to_s} should include #{@datetime_200403081200.to_s}"
    assert !eleven_thirty_to_two.include?(@datetime_200403110000), "Expression #{eleven_thirty_to_two.to_s} should not include #{@datetime_200403110000.to_s}"
    # => Tues,Thurs - 11:30am to 2pm
    expr2 = tues_thurs & eleven_thirty_to_two
    #
    # No parking: Mon Wed Fri, 8am - 11am
    #             Tu Thu, 11:30am - 2pm
    parking_ticket = expr1 | expr2
    assert parking_ticket.include?(@datetime_200403111215), "Expression #{parking_ticket.to_s} should include #{@datetime_200403111215.to_s}"
    assert parking_ticket.include?(@datetime_200403100915), "Expression #{parking_ticket.to_s} should include #{@datetime_200403100915.to_s}"
    assert parking_ticket.include?(@datetime_200403100800), "Expression #{parking_ticket.to_s} should include #{@datetime_200403100800.to_s}"
    assert !parking_ticket.include?(@datetime_200403110115), "Expression #{parking_ticket.to_s} should not include #{@datetime_200403110115.to_s}"

    # The preceeding example can be condensed to:
    #   e1 = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    #   e2 = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    #   ticket = e1 | e2
 end

end
