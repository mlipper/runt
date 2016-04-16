# Schedule Tutorial

* This tutorial assumes you are familiar with use of the Runt API to create temporal expressions. If you're unfamiliar with how and why to write temporal expressions, take a look at the temporal expression [tutorial](tutorial_te.md).

* In his [paper](http://martinfowler.com/apsupp/recurring.pdf) about recurring events, Martin Fowler also discusses a simple schedule API which is used, surprisingly enough, to build a schedule. We're not going to cover the pattern itself in this tutorial as Fowler already does a nice job. Because it is such a simple pattern (once you invent it!), you'll be able understand it even if you decide not to read his paper.

So, let's pretend that I own a car. Since I don't want to get a ticket, I decide to create an application which will tell me where and when I can park it on my street. (Since this is all make believe anyway, my car is a late 60's model black Ford Mustang with flame detailing (and on the back seat is one million dollars)).

We'll build a Runt Schedule that models the parking regulations. Our app  will check this Schedule at regular intervals and send us reminders to  move our car so we don't get a ticket. YAY!

First, let's visit the exciting world of NYC street cleaning regulations.  Let's pretend the following rules are in place for our block:

* For the north side of the street, there is no parking Monday, Wednesday, or Friday, from 8am thru 11am

* For the south side of the street, there is no parking Tuesday or Thursday between 11:30am and 2pm

Thus...

<pre>
    #############################   #############################
    #                           #   #                           #
    #       NO PARKING          #   #       NO PARKING          #
    #                           #   #                           #
    #  Mon, Wed, Fri 8am-11am   #   #  Tu, Th 11:30am-2:00pm    #
    #                           #   #                           #
    #                           #   #                           #
    #  Violators will be towed! #   #  Violaters will be towed! #
    #                           #   #                           #
    #############################   #############################
                # #                              # #
                # #                              # #
                # #                              # #

      North side of the street      South side of the street
</pre>

We'll start by creating temporal expressions which describe the verboten parking times:

```ruby
north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)

south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
```

What we need at this point is a way to write queries against these expressions to determine whether we need to send a reminder. For this purpose, we can use a Schedule and an associated Event, both of which are supplied by Runt.

```ruby
schedule = Schedule.new
```

A Schedule holds zero or more Event/TemporalExpression pairs, allowing clients to easily query and update TemporalExpressions as well perform certain range operations as we will see in a moment. We'll create two events, one for each side of the street:

```ruby
north_event = Event.new("north side")

south_event = Event.new("south side")
```

Now we add each event and its associated occurrence to our Schedule:

```ruby
schedule.add(north_event, north_expr)

schedule.add(south_event, south_expr)
```

An Event is simply a container for domain data. Although Runt uses Events  by default, Schedules will happily house any kind of Object. Internally, a Schedule is really just a Hash where the keys are whatever it is you are scheduling and the values are the TemporalExpressions you create.

```ruby
class Schedule
...

  def add(obj, expression)
    @elems[obj]=expression
  end
...
```

Now that we have a Schedule configured, we need something to check it and then let us know if we need to move the car. For this, we'll create a simple class called Reminder which will function as the "main-able" part of  our app.  We'll start by creating an easily testable constructor which will be passed a Schedule instance (like the one we just created) and an SMTP server.

```ruby
class Reminder

  attr_reader :schedule, :mail_server

  def initialize(schedule,mail_server)
    @schedule = schedule
    @mail_server = mail_server
  end
...
```

Being rabid foaming-at-the-mouth Agilists, we'll of course also create a unit test to  help flesh out the specifics of our new Reminder class. We'll create test fixtures using the Runt Objects described above.

```ruby
class ReminderTest < Test::Unit::TestCase

  include Runt

  def setup
    @schedule = Schedule.new
    @north_event = Event.new("north side of the street will be ticketed")
    north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    @schedule.add(@north_event, north_expr)
    @south_event = Event.new("south side of the street will be ticketed")
    south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    @schedule.add(@south_event, south_expr)
    @mail_server = MailServer.new
    @reminder = Reminder.new(@schedule, @mail_server)
    @saturday_at_10 = PDate.min(2007,11,24,10,0,0)
    @monday_at_10 = PDate.min(2007,11,26,10,0,0)
    @tuesday_at_noon = PDate.min(2007,11,27,12,0,0)
  end

  def test_initalize
    assert_same @schedule, @reminder.schedule, "Expected #{@schedule} instead was #{@reminder.schedule}"
    assert_same @mail_server, @reminder.mail_server, "Expected #{@mail_server} instead was #{@reminder.mail_server}"
  end
...
```

For the purposes of this tutorial, the mail server will simply be a stub to illustrate how a real one might be used.

```ruby
class MailServer

  Struct.new("Email",:to,:from,:subject,:text)

  def send(to, from, subject, text)
    Struct::Email.new(to, from, subject, text)
    # etc...
  end

end
```

Next, let's add a method to our Reminder class which actually checks our schedule using a date which is passed in as a parameter.

```ruby
class Reminder
...
  def check(date)
	return @schedule.events(date)
  end
...
```

The Schedule#events method will return an Array of Event Objects for any events which occur at the date and time given by the method's argument. Usage is easily demonstrated by a test case which makes use of the fixtures created by the TestCase#setup method defined above.

```ruby
class ReminderTest < Test::Unit::TestCase
  ...
  def test_check
    assert_equal 1, @reminder.check(@monday_at_10).size, "Unexpected size #{@reminder.check(@monday_at_10).size} returned"
    assert_same @north_event, @reminder.check(@monday_at_10)[0], "Expected Event #{@north_event}. Got #{@reminder.check(@monday_at_10)[0]}."
    assert_equal 1, @reminder.check(@tuesday_at_noon).size, "Unexpected size #{@reminder.check(@tuesday_at_noon).size} returned"
    assert_same @south_event, @reminder.check(@tuesday_at_noon)[0], "Expected Event #{@south_event}. Got #{@reminder.check(@tuesday_at_noon)[0]}."
    assert @reminder.check(@saturday_at_10).empty?, "Expected empty Array. Got #{@reminder.check(@saturday_at_10)}"
  end
  ...
```

There are other methods in the Schedule API which allow a client to query for information. Although we don't need them for this tutorial, I'll mention two briefly because they are generally useful. The first is Schedule#dates which will return an Array of PDate Objects which occur during the DateRange supplied as a parameter. The second is Schedule#include? which returns a boolean value indicating whether the Event occurs on the date which are both supplied as arguments.

Next, let's make use of the mail server argument given to the Reminder class in it's constructor. This is the method that will be called when a call to the Reminder#check method produces results.

```ruby
class Reminder
  ...
  def send(date)
    text = "Warning: " + events.join(', ')
    return @mail_server.send(TO, FROM, SUBJECT, text)
  end
  ...
```

Testing this is simple thanks to our MailServer stub which simply regurgitates the text argument it's passed as a result.

```ruby
class ReminderTest < Test::Unit::TestCase
  ...
  def test_send
    params = [@north_event, @south_event]
    result = @reminder.send(params)
    assert_email result, Reminder::TEXT + params.join(', ')
  end

  def assert_email(result, text)
    assert_equal Reminder::TO, result.to, "Unexpected value for 'to' field of Email Struct: #{result.to}"
    assert_equal Reminder::FROM, result.from, "Unexpected value for 'from' field of Email Struct: #{result.from}"
    assert_equal Reminder::SUBJECT, result.subject, "Unexpected value for 'subject' field of Email Struct: #{result.subject}"
    assert_equal text, result.text, "Unexpected value for 'text' field of Email Struct: #{result.text}"
  end
  ...
```

Note the `ReminderTest#assert_email` method we've added to make assertions common to multiple test cases.

Now, let's tie the whole thing together with a method which which checks for occuring Events and (upon finding some) sends a reminder. This method is really the only one in the Reminder class that needs to be public.

```ruby
class Reminder
  ...
  def run(date)
    result = self.check(date)
    self.send(result) if !result.empty?
  end
  ...

class ReminderTest < Test::Unit::TestCase
  ...
  def test_send
    params = [@north_event, @south_event]
    result = @reminder.send(params)
    assert_email result, Reminder::TEXT + params.join(', ')
  end
  ...
```

Finally, we'll cheat a bit and stitch every thing together so it can be run from a command line.

```ruby
include Runt

schedule = Schedule.new
north_event = Event.new("north side")
north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
schedule.add(north_event, north_expr)
south_event = Event.new("south side")
south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
schedule.add(south_event, south_expr)
reminder = Reminder.new(schedule, MailServer.new)
while true
  sleep 15.minutes
  reminder.run Time.now
end
```

So, here's all the code for this tutorial (it's in the Runt distribution under the examples folder):

```ruby
### schedule_tutorial.rb ###

#!/usr/bin/ruby

require 'runt'

class Reminder

    TO = "me@myselfandi.com"
    FROM = "reminder@daemon.net"
    SUBJECT = "Move your car!"
    TEXT = "Warning: "

    attr_reader :schedule, :mail_server

    def initialize(schedule,mail_server)
      @schedule = schedule
      @mail_server = mail_server
    end
    def run(date)
      result = self.check(date)
      self.send(result) if !result.empty?
    end
    def check(date)
      puts "Checking the schedule..." if $DEBUG
      return @schedule.events(date)
    end
    def send(events)
      text = TEXT + events.join(', ')
      return @mail_server.send(TO, FROM, SUBJECT, text)
    end

end

class MailServer
    Struct.new("Email",:to,:from,:subject,:text)
    def send(to, from, subject, text)
      puts "Sending message TO: #{to} FROM: #{from} RE: #{subject}..." if $DEBUG
      Struct::Email.new(to, from, subject, text)
     # etc...
    end

end

if __FILE__ == $0

    include Runt

    schedule = Schedule.new
    north_event = Event.new("north side")
    north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
    schedule.add(north_event, north_expr)
    south_event = Event.new("south side")
    south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
    schedule.add(south_event, south_expr)
    reminder = Reminder.new(schedule, MailServer.new)
    while true
      sleep 15.minutes
      reminder.run Time.now
    end

end

### schedule_tutorialtest.rb ###

#!/usr/bin/ruby

require 'test/unit' require 'runt' require 'schedule_tutorial'

class ReminderTest < Test::Unit::TestCase

    include Runt

    def setup
      @schedule = Schedule.new
      @north_event = Event.new("north side of the street will be ticketed")
      north_expr = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)
      @schedule.add(@north_event, north_expr)
      @south_event = Event.new("south side of the street will be ticketed")
      south_expr = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)
      @schedule.add(@south_event, south_expr)
      @mail_server = MailServer.new
      @reminder = Reminder.new(@schedule, @mail_server)
      @saturday_at_10 = PDate.min(2007,11,24,10,0,0)
      @monday_at_10 = PDate.min(2007,11,26,10,0,0)
      @tuesday_at_noon = PDate.min(2007,11,27,12,0,0)
    end
    def test_initalize
      assert_same @schedule, @reminder.schedule, "Expected #{@schedule} instead was #{@reminder.schedule}"
      assert_same @mail_server, @reminder.mail_server, "Expected #{@mail_server} instead was #{@reminder.mail_server}"
    end
    def test_send
      params = [@north_event, @south_event]
      result = @reminder.send(params)
      assert_email result, Reminder::TEXT + params.join(', ')
    end
    def test_check
      assert_equal 1, @reminder.check(@monday_at_10).size, "Unexpected size #{@reminder.check(@monday_at_10).size} returned"
      assert_same @north_event, @reminder.check(@monday_at_10)[0], "Expected Event #{@north_event}. Got #{@reminder.check(@monday_at_10)[0]}."
      assert_equal 1, @reminder.check(@tuesday_at_noon).size, "Unexpected size #{@reminder.check(@tuesday_at_noon).size} returned"
      assert_same @south_event, @reminder.check(@tuesday_at_noon)[0], "Expected Event #{@south_event}. Got #{@reminder.check(@tuesday_at_noon)[0]}."
      assert @reminder.check(@saturday_at_10).empty?, "Expected empty Array. Got #{@reminder.check(@saturday_at_10)}"
    end
    def test_run
      result = @reminder.run(@monday_at_10)
      assert_email result, Reminder::TEXT + @north_event.to_s
    end
    def assert_email(result, text)
      assert_equal Reminder::TO, result.to, "Unexpected value for 'to' field of Email Struct: #{result.to}"
      assert_equal Reminder::FROM, result.from, "Unexpected value for 'from' field of Email Struct: #{result.from}"
      assert_equal Reminder::SUBJECT, result.subject, "Unexpected value for 'subject' field of Email Struct: #{result.subject}"
      assert_equal text, result.text, "Unexpected value for 'text' field of Email Struct: #{result.text}"
    end

end
```

*See Also:*

* Temporal Expressions [tutorial](tutorial_te.md)
* Runt syntax sugar [tutorial](tutorial_sugar.md)
* Fowler's recurring event [pattern](http://martinfowler.com/apsupp/recurring.pdf)
* Other temporal [patterns](http://martinfowler.com/eaaDev/timeNarrative.html)

