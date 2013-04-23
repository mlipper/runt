#!/usr/bin/env ruby

require 'test/unit'
require 'date'
require 'runt'
require 'set'


# RFC 2445 is the iCalendar specification.  It includes dozens of
# specific examples that make great tests for Runt temporal expressions.
class ICalendarTest < Test::Unit::TestCase
  include Runt

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

    te = REWeek.new(Sun,Sat) & EveryTE.new(start_date, 2, DPrecision::DAY)    
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

    te = REWeek.new(Sun,Sat) & EveryTE.new(start_date, 10, DPrecision::DAY)
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

  # "Weekly for 10 occurrences"
  def test_example_6
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = start_date + 365 #Sep 2, 1998    
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10")
    
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
    
    te = EveryTE.new(start_date, 7, DPrecision::DAY) 
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end
  
  # "Weekly until December 24th, 1997"
  def test_example_7
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = start_date + 365 #Sep 2, 1998  
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971224T000000Z")
    
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
    
    te = BeforeTE.new(DateTime.parse("19971224T000000"), true) & EveryTE.new(start_date, 7, DPrecision::DAY) 
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Every other week - forever"
  def test_example_8
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = DateTime.parse("US-Eastern:19980201T090000") # Feb 1st, 1998
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;INTERVAL=2;WKST=SU")

    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971028T090000"), #Oct 28
      DateTime.parse("US-Eastern:19971111T090000"), #Nov 11
      DateTime.parse("US-Eastern:19971125T090000"), #Nov 25
      DateTime.parse("US-Eastern:19971209T090000"), #Dec 9
      DateTime.parse("US-Eastern:19971223T090000"), #Dec 23
      DateTime.parse("US-Eastern:19980106T090000"), #Jan 6
      DateTime.parse("US-Eastern:19980120T090000"), #Jan 20
    ]    

    te = EveryTE.new(start_date, 7*2, DPrecision::DAY) 
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Weekly on Tuesday and Thursday for 5 weeks (first example, using until)"
  def test_example_9_a
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = DateTime.parse("US-Eastern:19980101T090000") # Jan 1st, 1998
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
    
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
    
    te = BeforeTE.new(DateTime.parse("19971007T000000Z"), true) & (DIWeek.new(Tue) | DIWeek.new(Thu))
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end  

  # "Weekly on Tuesday and Thursday for 5 weeks (second example, using count)"
  def test_example_9_b
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = DateTime.parse("US-Eastern:19980101T090000") # Jan 1st, 1998

    #rrule = RecurrenceRule.new("FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH")
    
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
    
    te = DIWeek.new(Tue) | DIWeek.new(Thu)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end 
  
  # "Every other week on Monday, Wednesday, and Friday until December 24, 1997
  # but starting on Tuesday, September 2, 1997"
  def test_example_10
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = DateTime.parse("US-Eastern:19980201T090000") # Feb 1st, 1998
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR")
    
    expected = [
      #LJK: note that Sep 2nd is listed in the example, but it does not match the given RRULE.
      # It definitely is not rendered by the TE below, so I'm just commenting it out for more research.
      #DateTime.parse("US-Eastern:19970902T090000"), #Sep 2  
      
      DateTime.parse("US-Eastern:19970903T090000"), #Sep 3
      DateTime.parse("US-Eastern:19970905T090000"), #Sep 5
      DateTime.parse("US-Eastern:19970915T090000"), #Sep 15
      DateTime.parse("US-Eastern:19970917T090000"), #Sep 17
      DateTime.parse("US-Eastern:19970919T090000"), #Sep 19
      DateTime.parse("US-Eastern:19970929T090000"), #Sep 29
      DateTime.parse("US-Eastern:19971001T090000"), #Oct 1
      DateTime.parse("US-Eastern:19971003T090000"), #Oct 3
      DateTime.parse("US-Eastern:19971013T090000"), #Oct 13
      DateTime.parse("US-Eastern:19971015T090000"), #Oct 15
      DateTime.parse("US-Eastern:19971017T090000"), #Oct 17
      DateTime.parse("US-Eastern:19971027T090000"), #Oct 27
      DateTime.parse("US-Eastern:19971029T090000"), #Oct 29
      DateTime.parse("US-Eastern:19971031T090000"), #Oct 31
      DateTime.parse("US-Eastern:19971110T090000"), #Nov 10
      DateTime.parse("US-Eastern:19971112T090000"), #Nov 12
      DateTime.parse("US-Eastern:19971114T090000"), #Nov 14
      DateTime.parse("US-Eastern:19971124T090000"), #Nov 24
      DateTime.parse("US-Eastern:19971126T090000"), #Nov 26
      DateTime.parse("US-Eastern:19971128T090000"), #Nov 28
      DateTime.parse("US-Eastern:19971208T090000"), #Dec 8
      DateTime.parse("US-Eastern:19971210T090000"), #Dec 10
      DateTime.parse("US-Eastern:19971212T090000"), #Dec 12
      DateTime.parse("US-Eastern:19971222T090000"), #Dec 22
    ]    

    te = BeforeTE.new(DateTime.parse("19971224T000000Z"), true) & (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & EveryTE.new(start_date, 2, DPrecision::WEEK) 
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
  
  # "Every other week on Tuesday and Thursday, for 8 occurences"
  def test_example_11
    start_date = DateTime.parse("US-Eastern:19970902T090000") # Sep 2nd, 1997
    end_date   = DateTime.parse("US-Eastern:19980201T090000") # Feb 1st, 1998
    
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH")
    
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4
      DateTime.parse("US-Eastern:19970916T090000"), #Sep 16
      DateTime.parse("US-Eastern:19970918T090000"), #Sep 18
      DateTime.parse("US-Eastern:19970930T090000"), #Sep 30
      DateTime.parse("US-Eastern:19971002T090000"), #Oct 2
      DateTime.parse("US-Eastern:19971014T090000"), #Oct 14
      DateTime.parse("US-Eastern:19971016T090000"), #Oct 16
    ]    

    te = EveryTE.new(start_date, 2, DPrecision::WEEK) & (DIWeek.new(Tue) | DIWeek.new(Thu))
    results = te.dates(DateRange.new(start_date, end_date), 8)
    assert_equal(expected, results)        
  end

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
    
    te = EveryTE.new(start_date, 2, DPrecision::MONTH) & (DIMonth.new(1,0) | DIMonth.new(-1,0)) #first and last Sundays
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
  
    te = REMonth.new(10,15) & EveryTE.new(start_date, 18, DPrecision::MONTH)  #tenth through the fifteenth
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
  
    te = EveryTE.new(start_date, 2, DPrecision::MONTH) & DIWeek.new(Tuesday)
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
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

  # "Every other year on January, February, and March for 10 occurrences"
  def test_example_22
    start_date = DateTime.parse("US-Eastern:19970310T090000") #Mar 10, 1997
    end_date   = DateTime.parse("US-Eastern:20040401T090000") #Apr 1, 2004
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3")
  
    expected = [
      DateTime.parse("US-Eastern:19970310T090000"), #Mar 10, 1997
      DateTime.parse("US-Eastern:19990110T090000"), #Jan 10, 1999
      DateTime.parse("US-Eastern:19990210T090000"), #Feb 10, 1999
      DateTime.parse("US-Eastern:19990310T090000"), #Mar 10, 1999
      DateTime.parse("US-Eastern:20010110T090000"), #Jan 10, 2001
      DateTime.parse("US-Eastern:20010210T090000"), #Feb 10, 2001
      DateTime.parse("US-Eastern:20010310T090000"), #Mar 10, 2001
      DateTime.parse("US-Eastern:20030110T090000"), #Jan 10, 2003
      DateTime.parse("US-Eastern:20030210T090000"), #Feb 10, 2003
      DateTime.parse("US-Eastern:20030310T090000"), #Mar 10, 2003
    ]
    
    te = REMonth.new(start_date.day) & (REYear.new(1) | REYear.new(2) | REYear.new(3)) & EveryTE.new(start_date, 2, DPrecision::YEAR)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

=begin
  # "Every 3rd year on the 1st, 100th, and 200th day for 10 occurrences"
  def test_example_23
    start_date = DateTime.parse("US-Eastern:19970101T090000") #Jan 1, 1997
    end_date   = DateTime.parse("US-Eastern:20070401T090000") #Apr 1, 2007
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200")
  
    expected = [
      DateTime.parse("US-Eastern:19970101T090000"), #Jan 1,  1997
      DateTime.parse("US-Eastern:19970410T090000"), #Apr 10, 1997
      DateTime.parse("US-Eastern:19970719T090000"), #Jul 19, 1997
      DateTime.parse("US-Eastern:20000101T090000"), #Jan 1,  2000
      DateTime.parse("US-Eastern:20000409T090000"), #Apr 9,  2000
      DateTime.parse("US-Eastern:20000718T090000"), #Jul 18, 2000
      DateTime.parse("US-Eastern:20030101T090000"), #Jan 1,  2003
      DateTime.parse("US-Eastern:20030410T090000"), #Apr 10, 2003
      DateTime.parse("US-Eastern:20030719T090000"), #Jul 19, 2003
      DateTime.parse("US-Eastern:20060101T090000"), #Jan 1,  2006
    ]
    
    te = EveryTE.new(start_date, 3, DPrecision::YEAR) & (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end

  # "Every 20th Monday of the year, forever"
  def test_example_24
    start_date = DateTime.parse("US-Eastern:19970519T090000") #May 19, 1997
    end_date   = DateTime.parse("US-Eastern:20000101T090000") #Jan 1,  2000
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;BYDAY=20MO")
  
    expected = [
      DateTime.parse("US-Eastern:19970519T090000"), #May 19, 1997
      DateTime.parse("US-Eastern:19980518T090000"), #May 18, 1998
      DateTime.parse("US-Eastern:19990517T090000"), #May 17, 1999            
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Monday of week number 20 (where the default start of the week is Monday), forever"
  def test_example_25
    start_date = DateTime.parse("US-Eastern:19970512T090000") #May 12, 1997
    end_date   = DateTime.parse("US-Eastern:20000101T090000") #Jan 1,  2000
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO")
  
    expected = [
      DateTime.parse("US-Eastern:19970512T090000"), #May 12, 1997
      DateTime.parse("US-Eastern:19980511T090000"), #May 11, 1998
      DateTime.parse("US-Eastern:19990517T090000"), #May 17, 1999            
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 10)
    assert_equal(expected, results)
  end
=end

  # "Every Thursday in March, forever"
  def test_example_26
    start_date = DateTime.parse("US-Eastern:19970313T090000") #Mar 13, 1997
    end_date   = DateTime.parse("US-Eastern:20000101T090000") #Jan 1,  2000
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;BYMONTH=3;BYDAY=TH")
  
    expected = [
      DateTime.parse("US-Eastern:19970313T090000"), #Mar 13, 1997
      DateTime.parse("US-Eastern:19970320T090000"), #Mar 20, 1997
      DateTime.parse("US-Eastern:19970327T090000"), #Mar 27, 1997
      DateTime.parse("US-Eastern:19980305T090000"), #Mar 5,  1998
      DateTime.parse("US-Eastern:19980312T090000"), #Mar 12, 1998
      DateTime.parse("US-Eastern:19980319T090000"), #Mar 19, 1998
      DateTime.parse("US-Eastern:19980326T090000"), #Mar 26, 1998
      DateTime.parse("US-Eastern:19990304T090000"), #Mar 4,  1999
      DateTime.parse("US-Eastern:19990311T090000"), #Mar 11, 1999            
      DateTime.parse("US-Eastern:19990318T090000"), #Mar 18, 1999            
      DateTime.parse("US-Eastern:19990325T090000"), #Mar 25, 1999            
    ]
    
    te = REYear.new(3) & DIWeek.new(Thursday)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Every Thursday, but only during June, July, and August, forever"
  def test_example_27
    start_date = DateTime.parse("US-Eastern:19970605T090000") #Jun 5, 1997
    end_date   = DateTime.parse("US-Eastern:20000101T090000") #Jan 1, 2000
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8")
  
    expected = [
      DateTime.parse("US-Eastern:19970605T090000"), #Jun 5,  1997
      DateTime.parse("US-Eastern:19970612T090000"), #Jun 12, 1997
      DateTime.parse("US-Eastern:19970619T090000"), #Jun 19, 1997
      DateTime.parse("US-Eastern:19970626T090000"), #Jun 26, 1997
      DateTime.parse("US-Eastern:19970703T090000"), #Jul 3,  1997
      DateTime.parse("US-Eastern:19970710T090000"), #Jul 10, 1997
      DateTime.parse("US-Eastern:19970717T090000"), #Jul 17, 1997
      DateTime.parse("US-Eastern:19970724T090000"), #Jul 24, 1997
      DateTime.parse("US-Eastern:19970731T090000"), #Jul 31, 1997
      DateTime.parse("US-Eastern:19970807T090000"), #Aug 7,  1997
      DateTime.parse("US-Eastern:19970814T090000"), #Aug 14, 1997
      DateTime.parse("US-Eastern:19970821T090000"), #Aug 21, 1997
      DateTime.parse("US-Eastern:19970828T090000"), #Aug 28, 1997
      DateTime.parse("US-Eastern:19980604T090000"), #Jun 4,  1998
      DateTime.parse("US-Eastern:19980611T090000"), #Jun 11, 1998
      DateTime.parse("US-Eastern:19980618T090000"), #Jun 18, 1998
      DateTime.parse("US-Eastern:19980625T090000"), #Jun 25, 1998
      DateTime.parse("US-Eastern:19980702T090000"), #Jul 2,  1998
      DateTime.parse("US-Eastern:19980709T090000"), #Jul 9,  1998
      DateTime.parse("US-Eastern:19980716T090000"), #Jul 16, 1998
      DateTime.parse("US-Eastern:19980723T090000"), #Jul 23, 1998
      DateTime.parse("US-Eastern:19980730T090000"), #Jul 30, 1998
      DateTime.parse("US-Eastern:19980806T090000"), #Aug 6,  1998
      DateTime.parse("US-Eastern:19980813T090000"), #Aug 13, 1998
      DateTime.parse("US-Eastern:19980820T090000"), #Aug 20, 1998
      DateTime.parse("US-Eastern:19980827T090000"), #Aug 27, 1998     
      DateTime.parse("US-Eastern:19990603T090000"), #Jun 3,  1999
      DateTime.parse("US-Eastern:19990610T090000"), #Jun 10, 1999
      DateTime.parse("US-Eastern:19990617T090000"), #Jun 17, 1999
      DateTime.parse("US-Eastern:19990624T090000"), #Jun 24, 1999
      DateTime.parse("US-Eastern:19990701T090000"), #Jul 1,  1999
      DateTime.parse("US-Eastern:19990708T090000"), #Jul 8,  1999
      DateTime.parse("US-Eastern:19990715T090000"), #Jul 15, 1999
      DateTime.parse("US-Eastern:19990722T090000"), #Jul 22, 1999
      DateTime.parse("US-Eastern:19990729T090000"), #Jul 29, 1999
      DateTime.parse("US-Eastern:19990805T090000"), #Aug 5,  1999
      DateTime.parse("US-Eastern:19990812T090000"), #Aug 12, 1999
      DateTime.parse("US-Eastern:19990819T090000"), #Aug 19, 1999
      DateTime.parse("US-Eastern:19990826T090000"), #Aug 26, 1999       
    ]
    
    te = (REYear.new(6) | REYear.new(7) | REYear.new(8)) & DIWeek.new(Thursday)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Every Friday the 13th, forever"  
  # (LJK: aka the "Jason example") (yes, I know it's bad, but someone had to say it)
  def test_example_28
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997
    end_date   = DateTime.parse("US-Eastern:20001014T090000") #Oct 14, 2000
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13")
  
    expected = [
      DateTime.parse("US-Eastern:19980213T090000"), #Feb 13, 1998
      DateTime.parse("US-Eastern:19980313T090000"), #Mar 13, 1998
      DateTime.parse("US-Eastern:19981113T090000"), #Nov 13, 1998
      DateTime.parse("US-Eastern:19990813T090000"), #Aug 13, 1999
      DateTime.parse("US-Eastern:20001013T090000"), #Oct 13, 2000
    ]
    
    te = REMonth.new(13) & DIWeek.new(Friday)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "The first Saturday that follows the first Sunday of the month, forever"
  def test_example_29
    start_date = DateTime.parse("US-Eastern:19970913T090000") #Sep 13, 1997
    end_date   = DateTime.parse("US-Eastern:19980614T090000") #Jun 14, 1998
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13")
  
    expected = [
      DateTime.parse("US-Eastern:19970913T090000"), #Sep 13, 1997
      DateTime.parse("US-Eastern:19971011T090000"), #Oct 11, 1997
      DateTime.parse("US-Eastern:19971108T090000"), #Nov 8,  1997
      DateTime.parse("US-Eastern:19971213T090000"), #Dec 13, 1997
      DateTime.parse("US-Eastern:19980110T090000"), #Jan 10, 1998
      DateTime.parse("US-Eastern:19980207T090000"), #Feb 7,  1998
      DateTime.parse("US-Eastern:19980307T090000"), #Mar 7,  1998
      DateTime.parse("US-Eastern:19980411T090000"), #Apr 11, 1998
      DateTime.parse("US-Eastern:19980509T090000"), #May 9,  1998
      DateTime.parse("US-Eastern:19980613T090000"), #Jun 13, 1998
    ]
    
    te = (REMonth.new(7) | REMonth.new(8) | REMonth.new(9) | REMonth.new(10) | REMonth.new(11) | REMonth.new(12) | REMonth.new(13)) & DIWeek.new(Saturday)
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end
  
  # "Every four years, the first Tuesday after a Monday in November, forever 
  # (U.S. Presidential Election day)"
  def test_example_30
    start_date = DateTime.parse("US-Eastern:19961105T090000") #May 11, 1996
    end_date   = DateTime.parse("US-Eastern:20050101T090000") #Jan 1, 2005
  
    #rrule = RecurrenceRule.new("FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8")
  
    expected = [
      DateTime.parse("US-Eastern:19961105T090000"), #Nov 5, 1996
      DateTime.parse("US-Eastern:20001107T090000"), #Nov 7, 2000
      DateTime.parse("US-Eastern:20041102T090000"), #Nov 2, 2004            
    ]
    
    te = (REMonth.new(2) | REMonth.new(3) | REMonth.new(4) | REMonth.new(5) | REMonth.new(6) | REMonth.new(7) | REMonth.new(8)) & DIWeek.new(Tuesday) & REYear.new(11) & EveryTE.new(start_date, 4, DPrecision::YEAR) 
    results = te.dates(DateRange.new(start_date, end_date))
    assert_equal(expected, results)
  end  

=begin  
  # "The 3rd instance into the month of one of Tuesday, Wednesday, or Thursday, for the next three months"
  def test_example_31
    start_date = DateTime.parse("US-Eastern:19970904T090000") #Sep 4, 1997
    end_date   = DateTime.parse("US-Eastern:19971115T090000") #Nov 15, 1997 (LJK: my 22nd birthday)
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3")
  
    expected = [
      DateTime.parse("US-Eastern:19970904T090000"), #Sep 4, 1997
      DateTime.parse("US-Eastern:19971007T090000"), #Oct 7, 1997
      DateTime.parse("US-Eastern:19971106T090000"), #Nov 6, 1997
    ]
    
    te = DIMonth.new(3, Tuesday) | DIMonth.new(3, Wednesday) | DIMonth.new(3,Thursday)
    results = te.dates(DateRange.new(start_date, end_date), 3)
    debug(expected, results)
    assert_equal(expected, results)
  end

  # "The 2nd to last weekday of the month"
  def test_example_32
    start_date = DateTime.parse("US-Eastern:19970929T090000") #Sep 29, 1997
    end_date   = DateTime.parse("US-Eastern:19980401T090000") #Apr 1,  1998
  
    #rrule = RecurrenceRule.new("FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2")
  
    expected = [
      DateTime.parse("US-Eastern:19970929T090000"), #Sep 29, 1997
      DateTime.parse("US-Eastern:19971030T090000"), #Oct 30, 1997
      DateTime.parse("US-Eastern:19971127T090000"), #Nov 27, 1997
      DateTime.parse("US-Eastern:19971230T090000"), #Dec 30, 1997
      DateTime.parse("US-Eastern:19980129T090000"), #Jan 29, 1998
      DateTime.parse("US-Eastern:19980226T090000"), #Feb 26, 1998
      DateTime.parse("US-Eastern:19980330T090000"), #Mar 30, 1998
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 3)
    assert_equal(expected, results)
  end

  # "Every 3 hours from 9:00 AM to 5:00 PM on a specific day"
  def test_example_33
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997 at 9am
    end_date   = DateTime.parse("US-Eastern:19970902T170000") #Sep 2, 1997 at 5pm
  
    #rrule = RecurrenceRule.new("FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2, 1997 at 9am
      DateTime.parse("US-Eastern:19970902T120000"), #Sep 2, 1997 at 12pm
      DateTime.parse("US-Eastern:19970902T150000"), #Sep 2, 1997 at 3pm
    ]
    
    te = EveryTE.new(start_date, 3, DPrecision::HOUR) & BeforeTE.new(DateTime.parse("19970902T170000Z"))
    results = te.hours(HourRange.new(start_date, end_date))
    assert_equal(expected, results)
  end

  # "Every 15 minutes for 6 occurrences"
  def test_example_34
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997 at 9am
    end_date   = DateTime.parse("US-Eastern:19970903T090000") #Sep 3, 1997 at 9am
  
    #rrule = RecurrenceRule.new("FREQ=MINUTELY;INTERVAL=15;COUNT=6")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2, 1997 at 9:00 am
      DateTime.parse("US-Eastern:19970902T091500"), #Sep 2, 1997 at 9:15 am
      DateTime.parse("US-Eastern:19970902T093000"), #Sep 2, 1997 at 9:30 am
      DateTime.parse("US-Eastern:19970902T094500"), #Sep 2, 1997 at 9:45 am
      DateTime.parse("US-Eastern:19970902T100000"), #Sep 2, 1997 at 10:00 am
      DateTime.parse("US-Eastern:19970902T101500"), #Sep 2, 1997 at 10:15 am
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.hours(HourRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end

  # "Every hour and a half for 4 occurrences"
  def test_example_35
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997 at 9am
    end_date   = DateTime.parse("US-Eastern:19970903T090000") #Sep 3, 1997 at 9am
  
    #rrule = RecurrenceRule.new("FREQ=MINUTELY;INTERVAL=90;COUNT=4")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2, 1997 at 9:00  am
      DateTime.parse("US-Eastern:19970902T091500"), #Sep 2, 1997 at 10:30 am
      DateTime.parse("US-Eastern:19970902T093000"), #Sep 2, 1997 at 12:00 pm
      DateTime.parse("US-Eastern:19970902T094500"), #Sep 2, 1997 at 1:30  pm
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.hours(HourRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end

  # "Every 20 minutes from 9:00 AM to 4:40PM every day"
  # (using a daily rule)
  def test_example_36_a
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997 at 9am
    end_date   = DateTime.parse("US-Eastern:19970904T080000") #Sep 4, 1997 at 8am
  
    #rrule = RecurrenceRule.new("FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2, 1997 at 9:00 am
      DateTime.parse("US-Eastern:19970902T092000"), #Sep 2, 1997 at 9:20 am
      DateTime.parse("US-Eastern:19970902T094000"), #Sep 2, 1997 at 9:40 am      
      DateTime.parse("US-Eastern:19970902T100000"), #Sep 2, 1997 at 10:00 am
      DateTime.parse("US-Eastern:19970902T102000"), #Sep 2, 1997 at 10:20 am
      DateTime.parse("US-Eastern:19970902T104000"), #Sep 2, 1997 at 10:40 am
      DateTime.parse("US-Eastern:19970902T110000"), #Sep 2, 1997 at 11:00 am
      DateTime.parse("US-Eastern:19970902T112000"), #Sep 2, 1997 at 11:20 am
      DateTime.parse("US-Eastern:19970902T114000"), #Sep 2, 1997 at 11:40 am
      DateTime.parse("US-Eastern:19970902T120000"), #Sep 2, 1997 at 12:00 pm
      DateTime.parse("US-Eastern:19970902T122000"), #Sep 2, 1997 at 12:20 pm
      DateTime.parse("US-Eastern:19970902T124000"), #Sep 2, 1997 at 12:40 pm
      DateTime.parse("US-Eastern:19970902T130000"), #Sep 2, 1997 at 13:00 pm
      DateTime.parse("US-Eastern:19970902T132000"), #Sep 2, 1997 at 13:20 pm
      DateTime.parse("US-Eastern:19970902T134000"), #Sep 2, 1997 at 13:40 pm
      DateTime.parse("US-Eastern:19970902T140000"), #Sep 2, 1997 at 14:00 pm
      DateTime.parse("US-Eastern:19970902T142000"), #Sep 2, 1997 at 14:20 pm
      DateTime.parse("US-Eastern:19970902T144000"), #Sep 2, 1997 at 14:40 pm
      DateTime.parse("US-Eastern:19970902T150000"), #Sep 2, 1997 at 15:00 pm
      DateTime.parse("US-Eastern:19970902T152000"), #Sep 2, 1997 at 15:20 pm
      DateTime.parse("US-Eastern:19970902T154000"), #Sep 2, 1997 at 15:40 pm
      DateTime.parse("US-Eastern:19970902T160000"), #Sep 2, 1997 at 16:00 pm
      DateTime.parse("US-Eastern:19970902T162000"), #Sep 2, 1997 at 16:20 pm
      DateTime.parse("US-Eastern:19970902T164000"), #Sep 2, 1997 at 16:40 pm
      DateTime.parse("US-Eastern:19970903T090000"), #Sep 3, 1997 at 9:00 am
      DateTime.parse("US-Eastern:19970903T092000"), #Sep 3, 1997 at 9:20 am
      DateTime.parse("US-Eastern:19970903T094000"), #Sep 3, 1997 at 9:40 am      
      DateTime.parse("US-Eastern:19970903T100000"), #Sep 3, 1997 at 10:00 am
      DateTime.parse("US-Eastern:19970903T102000"), #Sep 3, 1997 at 10:20 am
      DateTime.parse("US-Eastern:19970903T104000"), #Sep 3, 1997 at 10:40 am
      DateTime.parse("US-Eastern:19970903T110000"), #Sep 3, 1997 at 11:00 am
      DateTime.parse("US-Eastern:19970903T112000"), #Sep 3, 1997 at 11:20 am
      DateTime.parse("US-Eastern:19970903T114000"), #Sep 3, 1997 at 11:40 am
      DateTime.parse("US-Eastern:19970903T120000"), #Sep 3, 1997 at 12:00 pm
      DateTime.parse("US-Eastern:19970903T122000"), #Sep 3, 1997 at 12:20 pm
      DateTime.parse("US-Eastern:19970903T124000"), #Sep 3, 1997 at 12:40 pm
      DateTime.parse("US-Eastern:19970903T130000"), #Sep 3, 1997 at 13:00 pm
      DateTime.parse("US-Eastern:19970903T132000"), #Sep 3, 1997 at 13:20 pm
      DateTime.parse("US-Eastern:19970903T134000"), #Sep 3, 1997 at 13:40 pm
      DateTime.parse("US-Eastern:19970903T140000"), #Sep 3, 1997 at 14:00 pm
      DateTime.parse("US-Eastern:19970903T142000"), #Sep 3, 1997 at 14:20 pm
      DateTime.parse("US-Eastern:19970903T144000"), #Sep 3, 1997 at 14:40 pm
      DateTime.parse("US-Eastern:19970903T150000"), #Sep 3, 1997 at 15:00 pm
      DateTime.parse("US-Eastern:19970903T152000"), #Sep 3, 1997 at 15:20 pm
      DateTime.parse("US-Eastern:19970903T154000"), #Sep 3, 1997 at 15:40 pm
      DateTime.parse("US-Eastern:19970903T160000"), #Sep 3, 1997 at 16:00 pm
      DateTime.parse("US-Eastern:19970903T162000"), #Sep 3, 1997 at 16:20 pm
      DateTime.parse("US-Eastern:19970903T164000"), #Sep 3, 1997 at 16:40 pm
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.hours(HourRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end

  # "Every 20 minutes from 9:00 AM to 4:40PM every day"
  # (using a minute-based rule)
  def test_example_36_b
    start_date = DateTime.parse("US-Eastern:19970902T090000") #Sep 2, 1997 at 9am
    end_date   = DateTime.parse("US-Eastern:19970904T080000") #Sep 4, 1997 at 8am
  
    #rrule = RecurrenceRule.new("FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16")
  
    expected = [
      DateTime.parse("US-Eastern:19970902T090000"), #Sep 2, 1997 at 9:00 am
      DateTime.parse("US-Eastern:19970902T092000"), #Sep 2, 1997 at 9:20 am
      DateTime.parse("US-Eastern:19970902T094000"), #Sep 2, 1997 at 9:40 am      
      DateTime.parse("US-Eastern:19970902T100000"), #Sep 2, 1997 at 10:00 am
      DateTime.parse("US-Eastern:19970902T102000"), #Sep 2, 1997 at 10:20 am
      DateTime.parse("US-Eastern:19970902T104000"), #Sep 2, 1997 at 10:40 am
      DateTime.parse("US-Eastern:19970902T110000"), #Sep 2, 1997 at 11:00 am
      DateTime.parse("US-Eastern:19970902T112000"), #Sep 2, 1997 at 11:20 am
      DateTime.parse("US-Eastern:19970902T114000"), #Sep 2, 1997 at 11:40 am
      DateTime.parse("US-Eastern:19970902T120000"), #Sep 2, 1997 at 12:00 pm
      DateTime.parse("US-Eastern:19970902T122000"), #Sep 2, 1997 at 12:20 pm
      DateTime.parse("US-Eastern:19970902T124000"), #Sep 2, 1997 at 12:40 pm
      DateTime.parse("US-Eastern:19970902T130000"), #Sep 2, 1997 at 13:00 pm
      DateTime.parse("US-Eastern:19970902T132000"), #Sep 2, 1997 at 13:20 pm
      DateTime.parse("US-Eastern:19970902T134000"), #Sep 2, 1997 at 13:40 pm
      DateTime.parse("US-Eastern:19970902T140000"), #Sep 2, 1997 at 14:00 pm
      DateTime.parse("US-Eastern:19970902T142000"), #Sep 2, 1997 at 14:20 pm
      DateTime.parse("US-Eastern:19970902T144000"), #Sep 2, 1997 at 14:40 pm
      DateTime.parse("US-Eastern:19970902T150000"), #Sep 2, 1997 at 15:00 pm
      DateTime.parse("US-Eastern:19970902T152000"), #Sep 2, 1997 at 15:20 pm
      DateTime.parse("US-Eastern:19970902T154000"), #Sep 2, 1997 at 15:40 pm
      DateTime.parse("US-Eastern:19970902T160000"), #Sep 2, 1997 at 16:00 pm
      DateTime.parse("US-Eastern:19970902T162000"), #Sep 2, 1997 at 16:20 pm
      DateTime.parse("US-Eastern:19970902T164000"), #Sep 2, 1997 at 16:40 pm
      DateTime.parse("US-Eastern:19970903T090000"), #Sep 3, 1997 at 9:00 am
      DateTime.parse("US-Eastern:19970903T092000"), #Sep 3, 1997 at 9:20 am
      DateTime.parse("US-Eastern:19970903T094000"), #Sep 3, 1997 at 9:40 am      
      DateTime.parse("US-Eastern:19970903T100000"), #Sep 3, 1997 at 10:00 am
      DateTime.parse("US-Eastern:19970903T102000"), #Sep 3, 1997 at 10:20 am
      DateTime.parse("US-Eastern:19970903T104000"), #Sep 3, 1997 at 10:40 am
      DateTime.parse("US-Eastern:19970903T110000"), #Sep 3, 1997 at 11:00 am
      DateTime.parse("US-Eastern:19970903T112000"), #Sep 3, 1997 at 11:20 am
      DateTime.parse("US-Eastern:19970903T114000"), #Sep 3, 1997 at 11:40 am
      DateTime.parse("US-Eastern:19970903T120000"), #Sep 3, 1997 at 12:00 pm
      DateTime.parse("US-Eastern:19970903T122000"), #Sep 3, 1997 at 12:20 pm
      DateTime.parse("US-Eastern:19970903T124000"), #Sep 3, 1997 at 12:40 pm
      DateTime.parse("US-Eastern:19970903T130000"), #Sep 3, 1997 at 13:00 pm
      DateTime.parse("US-Eastern:19970903T132000"), #Sep 3, 1997 at 13:20 pm
      DateTime.parse("US-Eastern:19970903T134000"), #Sep 3, 1997 at 13:40 pm
      DateTime.parse("US-Eastern:19970903T140000"), #Sep 3, 1997 at 14:00 pm
      DateTime.parse("US-Eastern:19970903T142000"), #Sep 3, 1997 at 14:20 pm
      DateTime.parse("US-Eastern:19970903T144000"), #Sep 3, 1997 at 14:40 pm
      DateTime.parse("US-Eastern:19970903T150000"), #Sep 3, 1997 at 15:00 pm
      DateTime.parse("US-Eastern:19970903T152000"), #Sep 3, 1997 at 15:20 pm
      DateTime.parse("US-Eastern:19970903T154000"), #Sep 3, 1997 at 15:40 pm
      DateTime.parse("US-Eastern:19970903T160000"), #Sep 3, 1997 at 16:00 pm
      DateTime.parse("US-Eastern:19970903T162000"), #Sep 3, 1997 at 16:20 pm
      DateTime.parse("US-Eastern:19970903T164000"), #Sep 3, 1997 at 16:40 pm
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.hours(HourRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end

  # "An example where the days generated makes a difference because of WKST"
  # (start of week day == Monday)
  def test_example_37_a
    start_date = DateTime.parse("US-Eastern:19970805T090000") #Aug 5, 1997
    end_date   = DateTime.parse("US-Eastern:19970901T080000") #Sep 1, 1997
  
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO")
  
    expected = [
      DateTime.parse("US-Eastern:19970805T090000"), #Aug 5,  1997
      DateTime.parse("US-Eastern:19970810T090000"), #Aug 10, 1997
      DateTime.parse("US-Eastern:19970819T090000"), #Aug 19, 1997
      DateTime.parse("US-Eastern:19970824T090000"), #Aug 24, 1997
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end
  
  # "An example where the days generated makes a difference because of WKST"
  # (start of week day == Sunday)
  def test_example_37_b
    start_date = DateTime.parse("US-Eastern:19970805T090000") #Aug 5, 1997
    end_date   = DateTime.parse("US-Eastern:19970901T080000") #Sep 1, 1997
  
    #rrule = RecurrenceRule.new("FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU")
  
    expected = [
      DateTime.parse("US-Eastern:19970805T090000"), #Aug 5,  1997
      DateTime.parse("US-Eastern:19970817T090000"), #Aug 17, 1997
      DateTime.parse("US-Eastern:19970819T090000"), #Aug 19, 1997
      DateTime.parse("US-Eastern:19970831T090000"), #Aug 31, 1997
    ]
    
    te = (REYear.new(6) | REYear.new(7)) & REMonth.new(start_date.day)
    results = te.dates(DateRange.new(start_date, end_date), 6)
    assert_equal(expected, results)
  end
=end

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
