#!/usr/bin/env ruby

require 'test/unit'
require 'date'
require 'runt'
require 'set'

include Runt

# RFC 2445 is the iCalendar specification.  It includes dozens of
# specific examples that make great tests for Runt temporal expressions.
class ICalendarTest < Test::Unit::TestCase

  # "Daily for 10 occurences"
  def test_example_1
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = start_date + 365 #Sep 2, 1998

    #rrule = RecurrenceRule.new("FREQ=DAILY;COUNT=10")
    te = REWeek.new(Sun, Sat)
    
    expected = ICalendarTest.get_date_range(start_date, DateTime.parse("US-Eastern:19970911T090000"))
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

  # "Daily until December 24, 1997"
  def test_example_2
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = start_date + 365 
    
    #rrule = RecurrenceRule.new("FREQ=DAILY;UNTIL=19971224T000000Z")
    te = BeforeTE.new(DateTime.parse("19971224T090000"), true) & REWeek.new(Sun, Sat)
    
    expected = ICalendarTest.get_date_range(start_date, DateTime.parse("19971224T090000"))
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
  
  # "Every other day - forever"
  def test_example_3
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2
    end_date   = DateTime.parse("US-Eastern:19971003T090000") #Oct 3
    
    #rrule = RecurrenceRule.new("FREQ=DAILY;INTERVAL=2")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970906T090000"), #Sep 6
      DateTime.parse("US-Eastern:19970908T090000"), #Sep 8 
      DateTime.parse("US-Eastern:19970910T090000"), #Sep 10
      DateTime.parse("US-Eastern:19970912T090000"), #Sep 12      
      DateTime.parse("US-Eastern:19970914T090000"), #Sep 14
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970920T090000"), #Sep 20
      DateTime.parse("US-Eastern:19970922T090000"), #Sep 22
      DateTime.parse("US-Eastern:19970924T090000"), #Sep 24
      DateTime.parse("US-Eastern:19970926T090000"), #Sep 26
      DateTime.parse("US-Eastern:19970928T090000"), #Sep 28
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30 
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 02                                         
    ]

    #we have to set the precision for use in EveryTE
    start_date.date_precision = DPrecision::DAY    
    te = REWeek.new(Sun,Sat) & EveryTE.new(start_date, 2)    
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)    
    
    #alternatively we could use the DayIntervalTE
    te = DayIntervalTE.new(start_date, 2)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)      
  end

  # "Every 10 days, 5 occurrences"
  def test_example_4
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = start_date + 180 #Mar 1, 1998 (halved the normal test range because EveryTE is pretty slow)

    #rrule = RecurrenceRule.new("FREQ=DAILY;INTERVAL=10;COUNT=5")

    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970912T090000"), #Sep 12
      DateTime.parse("US-Eastern:19970922T090000"), #Sep 22
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
      DateTime.parse("US-Eastern:19971012T090000"), #Oct 12
    ]

    #we have to set the precision for use in EveryTE
    start_date.date_precision = DPrecision::DAY    
    te = REWeek.new(Sun,Sat) & EveryTE.new(start_date, 10)
    results = te.dates(DateRange.new(start_date, end_date), 5)
    assert_equal(expected, results)    
    
    #alternatively we could use the DayIntervalTE
    te = DayIntervalTE.new(start_date, 10)
    results = te.dates(DateRange.new(start_date, end_date), 5 )
    assert_equal(expected, results)      
  end

  # "Every day in January, for 3 years" (first example, yearly byday)
  def test_example_5_a
    start_date = DateTime.parse("US-Eastern:19980101T090000") #Jan 1, 1998
    end_date   = start_date + 365 + 365 + 366 + 31 #Feb 1, 2001
    
    #rrule = RecurrenceRule.new("FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA")
    
    expected = []
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:19980101T090000"), DateTime.parse("US-Eastern:19980131T090000"))
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:19990101T090000"), DateTime.parse("US-Eastern:19990131T090000"))
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:20000101T090000"), DateTime.parse("US-Eastern:20000131T090000"))
    
    te = BeforeTE.new(DateTime.parse("20000131T090000"), true) & REYear.new(1) & (DIWeek.new(Sun) | DIWeek.new(Mon) | DIWeek.new(Tue) | DIWeek.new(Wed) | DIWeek.new(Thu) | DIWeek.new(Fri) | DIWeek.new(Sat))
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
  
  # "Every day in January, for 3 years" (second example, daily bymonth)
  def test_example_5_b
    start_date = DateTime.parse("US-Eastern:19980101T090000")
    end_date   = start_date + 365 + 365 + 366 + 31 #Feb 1, 2001
    
    #rrule = RecurrenceRule.new("FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1")
    
    expected = []
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:19980101T090000"), DateTime.parse("US-Eastern:19980131T090000"))
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:19990101T090000"), DateTime.parse("US-Eastern:19990131T090000"))
    expected += ICalendarTest.get_date_range(DateTime.parse("US-Eastern:20000101T090000"), DateTime.parse("US-Eastern:20000131T090000"))
    
    te = BeforeTE.new(DateTime.parse("20000131T090000"), true) & REWeek.new(Sun, Sat) & REYear.new(1)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

=begin
  # "Weekly for 10 occurrences"
  def test_example_6
    start_date = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971007T090000"), #Oct 7
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971021T090000"), #Oct 21
      DateTime.parse("US-Eastern:19971028T090000"), #Oct 28
      DateTime.parse("US-Eastern:19971104T090000"), #Nov 4
    ]
    results = te.dates(DateRange.new(start_date, END_DATE))
    
    assert_equal(expected, results)
  end

  # "Weekly until December 24th, 1997"
  def test_example_7
    start_date = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971224T000000Z")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971007T090000"), #Oct 7
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971021T090000"), #Oct 21
      DateTime.parse("US-Eastern:19971028T090000"), #Oct 28
      DateTime.parse("US-Eastern:19971104T090000"), #Nov 4
      DateTime.parse("US-Eastern:19971111T090000"), #Nov 11
      DateTime.parse("US-Eastern:19971118T090000"), #Nov 18
      DateTime.parse("US-Eastern:19971125T090000"), #Nov 25
      DateTime.parse("US-Eastern:19971202T090000"), #Dec 2
      DateTime.parse("US-Eastern:19971209T090000"), #Dec 9
      DateTime.parse("US-Eastern:19971216T090000"), #Dec 16
      DateTime.parse("US-Eastern:19971223T090000"), #Dec 23
    ]
    results = te.dates(DateRange.new(start_date, END_DATE))
    
    assert_equal(expected, results)
  end
  
  # "Every other week - forever"
  def test_example_8
  end
  
  # "Weekly on Tuesday and Thursday for 5 weeks (first example, using until)"
  def test_example_9_a
    start_date = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970911T090000"), #Sep 11
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970925T090000"), #Sep 25
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
    ]
    results = te.dates(DateRange.new(start_date, END_DATE))
    
    assert_equal(expected, results)
  end  

  # "Weekly on Tuesday and Thursday for 5 weeks (second example, using count)"
  def test_example_9_b
    start_date = DateTime.parse("US-Eastern:19970902T090000")
    rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 9
      DateTime.parse("US-Eastern:19970911T090000"), #Sep 11
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23
      DateTime.parse("US-Eastern:19970925T090000"), #Sep 25
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
    ]
    results = te.dates(DateRange.new(start_date, END_DATE))
    
    assert_equal(expected, results)
  end 

  # "Every other week on Monday, Wednesday, and Friday until December 24, 1997
  # but starting on Tuesday, September 2, 1997"
  def test_example_10
  end
  
  # "Every other week on Tuesday and Thursday, for 8 occurences"
  def test_example_11
  end
=end 

  # "Monthly on the 1st Friday for ten occurences"
  def test_example_12
    start_date = DateTime.parse("US-Eastern:19970905T090000") #Sep 5, 1997
    end_date   = start_date + 365  #Sep 5, 1998
    
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;COUNT=10;BYDAY=1FR")
    
    expected = [
      DateTime.parse("US-Eastern:19970905T090000"), #Sep 5
      DateTime.parse("US-Eastern:19971003T090000"), #Oct 3
      DateTime.parse("US-Eastern:19971107T090000"), #Nov 7
      DateTime.parse("US-Eastern:19971205T090000"), #Dec 5
      DateTime.parse("US-Eastern:19980102T090000"), #Jan 2
      DateTime.parse("US-Eastern:19980206T090000"), #Feb 6
      DateTime.parse("US-Eastern:19980306T090000"), #Mar 6
      DateTime.parse("US-Eastern:19980403T090000"), #Apr 3
      DateTime.parse("US-Eastern:19980501T090000"), #May 1
      DateTime.parse("US-Eastern:19980605T090000"), #Jun 5
    ]
    
    te = DIMonth.new(1,5) #first friday
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end
  
  # "Monthly on the 1st Friday until December 24, 1997"
  def test_example_13
    start_date = DateTime.parse("US-Eastern:19970905T090000") #Sep 5, 1997
    end_date   = start_date + 365  #Sep 5, 1998
    
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;UNTIL=19971224T000000;BYDAY=1FR")
    
    expected = [
      DateTime.parse("US-Eastern:19970905T090000"), #Sep 5
      DateTime.parse("US-Eastern:19971003T090000"), #Oct 3
      DateTime.parse("US-Eastern:19971107T090000"), #Nov 7
      DateTime.parse("US-Eastern:19971205T090000"), #Dec 5
    ]
    
    te = BeforeTE.new(DateTime.parse("US-Eastern:19971224T000000")) & DIMonth.new(1,5) #first friday
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
  
  # "Every other month on the 1st and last Sunday of the month for 10 occurences"
  def test_example_14
    start_date = DateTime.parse("US-Eastern:19970907T090000") #Sep 7, 1997
    end_date   = start_date + 365  #Sep 7, 1998
    
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU")
    
    expected = [
      DateTime.parse("US-Eastern:19970907T090000"), #Sep 5
      DateTime.parse("US-Eastern:19970928T090000"), #Sep 28
      DateTime.parse("US-Eastern:19971102T090000"), #Nov 2
      DateTime.parse("US-Eastern:19971130T090000"), #Nov 30
      DateTime.parse("US-Eastern:19980104T090000"), #Jan 4
      DateTime.parse("US-Eastern:19980125T090000"), #Jan 25
      DateTime.parse("US-Eastern:19980301T090000"), #Mar 1
      DateTime.parse("US-Eastern:19980329T090000"), #Mar 29
      DateTime.parse("US-Eastern:19980503T090000"), #May 3
      DateTime.parse("US-Eastern:19980531T090000"), #May 31
    ]
    
    #set the date precision for the EveryTe
    start_date.date_precision = DPrecision::MONTH
    te = EveryTE.new(start_date, 2) & (DIMonth.new(1,0) | DIMonth.new(-1,0)) #first and last Sundays
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end
  
  # "Monthly on the second to last Monday of the month for 6 months"
  def test_example_15
    start_date = DateTime.parse("US-Eastern:19970922T090000") #Sep 22, 1997
    end_date   = start_date + 365  #Sep 22, 1998
    
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;COUNT=6;BYDAY=-2MO")
    
    expected = [
      DateTime.parse("US-Eastern:19970922T090000"), #Sep 22
      DateTime.parse("US-Eastern:19971020T090000"), #Oct 20
      DateTime.parse("US-Eastern:19971117T090000"), #Nov 17
      DateTime.parse("US-Eastern:19971222T090000"), #Dec 22
      DateTime.parse("US-Eastern:19980119T090000"), #Jan 19
      DateTime.parse("US-Eastern:19980216T090000"), #Feb 16
    ]
    
    te = DIMonth.new(-2,1) #second to last Monday
    results = te.dates(DateRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end
  
=begin
  #### NOTE: Runt does not currently support negative day of month references!
  # "Monthly on the third to the last day of the month, forever"
  def test_example_16
    start_date = DateTime.parse("US-Eastern:19970922T090000") #Sep 22, 1997
    end_date   = DateTime.parse("US-Eastern:19980301T090000"), #Mar 1, 1998
    
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;BYMONTHDAY=-3")
    
    expected = [
      DateTime.parse("US-Eastern:19970928T090000"), #Sep 28
      DateTime.parse("US-Eastern:19971029T090000"), #Oct 29
      DateTime.parse("US-Eastern:19971128T090000"), #Nov 28
      DateTime.parse("US-Eastern:19971229T090000"), #Dec 29
      DateTime.parse("US-Eastern:19980129T090000"), #Jan 29
      DateTime.parse("US-Eastern:19980226T090000"), #Feb 26
    ]
    
    te = REMonth.new(-3) #third to last day of the month
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
=end

  # "Monthly on the 2nd and 15th of the month for 10 occurences"
  def test_example_17
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = start_date + 365 #Sep 2, 1998
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970915T090000"), #Sep 15
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
      DateTime.parse("US-Eastern:19971015T090000"), #Oct 15
      DateTime.parse("US-Eastern:19971102T090000"), #Nov 2
      DateTime.parse("US-Eastern:19971115T090000"), #Nov 15
      DateTime.parse("US-Eastern:19971202T090000"), #Dec 2
      DateTime.parse("US-Eastern:19971215T090000"), #Dec 15      
      DateTime.parse("US-Eastern:19980102T090000"), #Jan 2
      DateTime.parse("US-Eastern:19980115T090000"), #Jan 15
    ]
  
    te = REMonth.new(2) | REMonth.new(15) #second or fifteenth of the month
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

=begin
  #### NOTE: Runt does not currently support negative day of month references!
  # "Monthly on the first and last day of the month for 10 occurences"
  def test_example_18
    start_date = DateTime.parse("US-Eastern:19970930T090000") #Sep 30, 1997
    end_date   = start_date + 365 #Sep 30, 1998
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1")
  
    expected = [
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971001T090000"), #Oct 1
      DateTime.parse("US-Eastern:19971031T090000"), #Oct 31
      DateTime.parse("US-Eastern:19971101T090000"), #Nov 1
      DateTime.parse("US-Eastern:19971130T090000"), #Nov 30
      DateTime.parse("US-Eastern:19971201T090000"), #Dec 1
      DateTime.parse("US-Eastern:19971231T090000"), #Dec 31      
      DateTime.parse("US-Eastern:19980101T090000"), #Jan 1
      DateTime.parse("US-Eastern:19980131T090000"), #Jan 31
      DateTime.parse("US-Eastern:19980201T090000"), #Feb 1      
    ]
  
    te = REMonth.new(1) | REMonth.new(-1) #first and last days of the month
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end
=end

  # "Every 18 months on the 10th thru 15th of the month for 10 occurrences"
  def test_example_19
    start_date = DateTime.parse("US-Eastern:19970910T090000") #Sep 10, 1997
    end_date   = start_date + 365 + 365 #Sep 10, 1999
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15")
  
    expected = [
      DateTime.parse("US-Eastern:19970910T090000"), #Sep 10, 1997
      DateTime.parse("US-Eastern:19970911T090000"), #Sep 11, 1997
      DateTime.parse("US-Eastern:19970912T090000"), #Sep 12, 1997
      DateTime.parse("US-Eastern:19970913T090000"), #Sep 13, 1997
      DateTime.parse("US-Eastern:19970914T090000"), #Sep 14, 1997
      DateTime.parse("US-Eastern:19970915T090000"), #Sep 15, 1997
      DateTime.parse("US-Eastern:19990310T090000"), #Mar 10, 1999
      DateTime.parse("US-Eastern:19990311T090000"), #Mar 11, 1999
      DateTime.parse("US-Eastern:19990312T090000"), #Mar 12, 1999
      DateTime.parse("US-Eastern:19990313T090000"), #Mar 13, 1999            
    ]
  
    #we have to set the precision for use in EveryTE
    start_date.date_precision = DPrecision::MONTH    
    te = EveryTE.new(start_date, 18) & REMonth.new(10,15)  #tenth through the fifteenth
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

  # "Every Tuesday, every other month"
  def test_example_20
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = start_date + 220 #Oct 4, 1998
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;INTERVAL=2;BYDAY=TU)
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 02, 1997
      DateTime.parse("US-Eastern:19970909T090000"), #Sep 09, 1997
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16, 1997
      DateTime.parse("US-Eastern:19970923T090000"), #Sep 23, 1997
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30, 1997
      DateTime.parse("US-Eastern:19971104T090000"), #Nov 04, 1997
      DateTime.parse("US-Eastern:19971111T090000"), #Nov 11, 1997
      DateTime.parse("US-Eastern:19971118T090000"), #Nov 18, 1997
      DateTime.parse("US-Eastern:19971125T090000"), #Nov 25, 1997            
      DateTime.parse("US-Eastern:19980106T090000"), #Jan 06, 1998
      DateTime.parse("US-Eastern:19980113T090000"), #Jan 13, 1998
      DateTime.parse("US-Eastern:19980120T090000"), #Jan 20, 1998
      DateTime.parse("US-Eastern:19980127T090000"), #Jan 27, 1998
      DateTime.parse("US-Eastern:19980303T090000"), #Mar 03, 1998                                          
      DateTime.parse("US-Eastern:19980310T090000"), #Mar 10, 1998                                          
      DateTime.parse("US-Eastern:19980317T090000"), #Mar 17, 1998                                          
      DateTime.parse("US-Eastern:19980324T090000"), #Mar 24, 1998                                          
      DateTime.parse("US-Eastern:19980331T090000"), #Mar 31, 1998                                                                  
    ]
  
    #we have to set the precision for use in EveryTE
    start_date.date_precision = DPrecision::MONTH    
    te = EveryTE.new(start_date, 2) & DIWeek.new(Tuesday)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Yearly in June and July for 10 occurrences"
  def test_example_21
    start_date = DateTime.parse("US-Eastern:19970610T090000") #June 10, 1997
    end_date   = DateTime.parse("US-Eastern:20020725T090000") #July 25, 2002
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;COUNT=10;BYMONTH=6,7)
  
    expected = [
      DateTime.parse("US-Eastern:19970610T090000"), #Jun 10, 1997
      DateTime.parse("US-Eastern:19970710T090000"), #Jul 10, 1997
      
      DateTime.parse("US-Eastern:19980610T090000"), #Jun 10, 1998
      DateTime.parse("US-Eastern:19980710T090000"), #Jul 10, 1998
              
      DateTime.parse("US-Eastern:19990610T090000"), #Jun 10, 1999
      DateTime.parse("US-Eastern:19990710T090000"), #Jul 10, 1999
      
      DateTime.parse("US-Eastern:20000610T090000"), #Jun 10, 2000
      DateTime.parse("US-Eastern:20000710T090000"), #Jul 10, 2000
      
      DateTime.parse("US-Eastern:20010610T090000"), #Jun 10, 2001
      DateTime.parse("US-Eastern:20010710T090000"), #Jul 10, 2001
    ]
    
    #we have to set the precision for use in EveryTE
    start_date.date_precision = DPrecision::YEAR
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

  def debug(expected, results)
    puts "expected:"
    expected.each {|date| puts date}
    puts "results:"
    results.each {|date| puts date}
  end
  
  #convenience method for creating an array of dates, one per day, from a start to an end date
  def self.get_date_range(start_date, end_date)
    dates = []
    start_date.upto(end_date) {|date| dates << date}
    dates
  end
end
