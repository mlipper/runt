
#!/usr/bin/env ruby

require 'baseexpressiontest'

# Unit tests for composite temporal expressions
# Author:: Matthew Lipper

class CombinedExpressionTest < BaseExpressionTest


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
    assert job.include?(last_monday_in_may)
    assert job.include?(@pdate_200605301400)
    # Add Diff expression
    job_with_holiday = job - last_monday_in_may
    assert !job_with_holiday.include?(last_monday_in_may)
    # Still have to work on Tuesday
    assert job.include?(@pdate_200605301400)
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
    june_through_august=REYear.new(6,First,8)
    assert june_through_august.include?(@pdate_20040704)
    #Finally!
    summer_time = last_week_of_may | first_week_of_september | june_through_august

    #Will work, but will be incredibly slow:
    #  assert(summer_time.include?(PDate.min(2004,5,31,0,0)))
    assert summer_time.include?(@pdate_20040531)
    assert summer_time.include?(@pdate_20040704)
    #also works...also slow:
    #  assert(!summer_time.include?(PDate.min(2004,9,6,0,0)))
    assert(!summer_time.include?(PDate.hour(2004,9,6,0,0)))

  end
  def test_nyc_parking_te

    #Monday, Wednesday, Friday
    mon_wed_fri = DIWeek.new(Mon) | \
                    DIWeek.new(Wed) | \
                      DIWeek.new(Fri)


    #Wednesday (at 7:15pm - ignored)
    assert(mon_wed_fri.include?(DateTime.new(2004,3,10,19,15)))

    #Sunday (at 9:00am - ignored)
    assert(!mon_wed_fri.include?(DateTime.new(2004,3,14,9,00)))

    #8am to 11am
    eight_to_eleven = REDay.new(8,00,11,00)

    #=> Mon,Wed,Fri - 8am to 11am
    expr1 = mon_wed_fri & eight_to_eleven

    #Tuesdays, Thursdays
    tues_thurs = DIWeek.new(Tue) | DIWeek.new(Thu)

    #11:30am to 2pm
    eleven_thirty_to_two = REDay.new(11,30,14,00)

    #Noon (on Monday - ignored)
    assert(eleven_thirty_to_two.include?(DateTime.new(2004,3,8,12,00)))

    #Midnite (on Thursday - ignored)
    assert(!eleven_thirty_to_two.include?(DateTime.new(2004,3,11,00,00)))


    #=> Tues,Thurs - 11:30am to 2pm
    expr2 = tues_thurs & eleven_thirty_to_two

    #
    #Sigh...now if I can only get my dad to remember this...
    #
    parking_ticket = expr1 | expr2

    assert(parking_ticket.include?(DateTime.new(2004,3,11,12,15)))
    assert(parking_ticket.include?(DateTime.new(2004,3,10,9,15)))
    assert(parking_ticket.include?(DateTime.new(2004,3,10,8,00)))

    assert(!parking_ticket.include?(DateTime.new(2004,3,11,1,15)))

    # Simplified
    e1 = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    e2 = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    ticket = expr1 | expr2
    assert(ticket.include?(DateTime.new(2004,3,11,12,15)))
    assert(ticket.include?(DateTime.new(2004,3,10,9,15)))
    assert(ticket.include?(DateTime.new(2004,3,10,8,00)))
    assert(!ticket.include?(DateTime.new(2004,3,11,1,15)))
 end

end
