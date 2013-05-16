# Temporal Expressions Tutorial

Based on a [pattern](http://martinfowler.com/apsupp/recurring.pdf) created by Martin Fowler, temporal expressions define points or ranges in time using *set expressions*. This means, an application developer can precisely describe recurring events without resorting to hacking out a big-ol' nasty enumerated list of dates.

For example, say you wanted to schedule an event that occurred annually on the last Thursday of every August. You might start out by doing something like this:

```ruby
require 'date'

some_dates = [Date.new(2002,8,29),Date.new(2003,8,28),Date.new(2004,8,26)]
```

This is fine for two or three years, but what about for thirty years? What if you want to say every Monday, Tuesday and Friday, between 3 and 5pm for the next fifty years?

As Fowler notes in his paper, TemporalExpressions(`TE`s for short) provide a simple pattern language for defining a given set of dates and/or times. They can be mixed and matched as necessary, providing modular component expressions that can be combined to define arbitrarily complex periods of time.

## Example 1
**Define An Expression That Says: 'the last Thursday in August'**

```ruby
require 'runt'
require 'date'

last_thursday = DIMonth.new(Last_of,Thursday)

august = REYear.new(8)

expr = last_thursday & august

expr.include?(Date.new(2002,8,29)) #Thurs 8/29/02 => true
expr.include?(Date.new(2003,8,28)) #Thurs 8/28/03 => true
expr.include?(Date.new(2004,8,26)) #Thurs 8/26/04 => true

expr.include?(Date.new(2004,3,18)) #Thurs 3/18/04 => false
expr.include?(Date.new(2004,8,27)) #Fri 8/27/04 => false
```

A couple things are worth noting before we move on to more complicated expressions. 

Clients use temporal expressions by creating specific instances (`DIMonth` == day in month, `REYear` == range each year) and then, optionally, combining them using various familiar operators  `( & , | , - )`.

Semantically, the `&` operator on line 8 behaves much like the standard Ruby short-circuit operator `&&`. However, instead of returning a boolean value, a new composite `TE` is instead created and returned. This new expression is the logical intersection of everything matched by **both** arguments `&`.

In the example above, line  4:

```ruby
last_thursday = DIMonth.new(Last_of,Thursday)
```

will match the last Thursday of **any** month and line 6:

```ruby
august = REYear.new(8)
```

will match **any** date or date range occurring within the month of August. Thus, combining them, you have 'the last Thursday' **AND** 'the month of August'.

By contrast:

```ruby
expr = DIMonth.new(Last_of,Thursday) | REYear.new(8)
```

will all match dates and ranges occurring within 'the last Thursday' **OR** 'the month of August'.

Now what? You can see that calling the `#include?` method will let you know whether the expression you've defined includes a given date (or, in some cases, a range, or another TE). This is much like the way you use the standard `Range#include?`.

## Example 2
**Define: 'Street Cleaning Rules/Alternate Side Parking in NYC'**

In his [paper](http://martinfowler.com/apsupp/recurring.pdf), Fowler uses Boston parking regulations to illustrate some examples. Since I'm from New York City, and Boston-related examples might cause an allergic reaction, I'll use NYC's street cleaning and parking [calendar](http://www.nyc.gov/html/dot/html/motorist/scrintro.html#street)
instead. Since I'm not *completely* insane, I'll only use a small subset of the City's actual rules.

On my block, parking is prohibited on the north side of the street Monday, Wednesday, and Friday between the hours of 8am to 11am, and on Tuesday and Thursday from 11:30am to 2pm...let's start by selecting days in the week.

Monday **OR** Wednesday **OR** Friday:

```ruby
mon_wed_fri = DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)

mon_wed_fri.include?( DateTime.new(2004,3,10,19,15) )     # Wed => true
mon_wed_fri.include?( DateTime.new(2004,3,14,9,00) )      # Sun => false
```

8am to 11am: 

```ruby
eight_to_eleven = REDay.new(8,00,11,00)
```
combine the two:

```ruby
expr1 = mon_wed_fri & eight_to_eleven
```

and, logically speaking, we now have '(Mon **OR** Wed **OR** Fri)  **AND** (8am to 11am)'. We're halfway there. 

Tuesdays and Thursdays:

```ruby
tues_thurs = DIWeek.new(Tue) | DIWeek.new(Thu)
```

11:30am to 2pm:

```ruby
eleven_thirty_to_two = REDay.new(11,30,14,00)

eleven_thirty_to_two.include?( DateTime.new(2004,3,8,12,00) )   # Noon => true
eleven_thirty_to_two.include?( DateTime.new(2004,3,11,00,00) )  # Midnite => false

expr2 = tues_thurs & eleven_thirty_to_two
```

`expr2` says '(Tues **OR** Thurs) **AND** (11:30am to 2pm)'.

and finally:

```ruby
ticket = expr1 | expr2
```

Or, logically, ((Mon **OR** Wed **OR** Fri) **AND** (8am to 11am)) **OR** ((Tues OR Thurs) **AND** (11:30am to 2pm))

Let's re-write this without all the noise:

```ruby
expr1 = (DIWeek.new(Mon) | DIWeek.new(Wed) | DIWeek.new(Fri)) & REDay.new(8,00,11,00)

expr2 = (DIWeek.new(Tue) | DIWeek.new(Thu)) & REDay.new(11,30,14,00)

ticket = expr1 | expr2

ticket.include?( DateTime.new(2004,3,11,12,15) )  # => true

ticket.include?( DateTime.new(2004,3,10,9,15) )   # => true

ticket.include?( DateTime.new(2004,3,10,8,00) )   # => true

ticket.include?( DateTime.new(2004,3,11,1,15) )   # => false
```

Sigh...now if I can only get my dad to remember this...

These are simple examples, but they demonstrate how temporal expressions can be used instead of an enumerated list of date values to define patterns of recurrence. There are many other temporal expressions, and, more importantly, once you get the hang of it, it's easy to write your own.

Fowler's [paper](http://martinfowler.com/apsupp/recurring.pdf) also goes on to describe another element of this pattern: the `Schedule`. See the schedule [tutorial](tutorial_schedule.md) for details.

*See Also:*

* Schedule [tutorial](tutorial_schedule.md)
* Sugar [tutorial](tutorial_sugar.md)
* Martin Fowler's recurring event [pattern](http://martinfowler.com/apsupp/recurring.pdf)
* Other temporal [patterns](http://martinfowler.com/eaaDev/timeNarrative.html)

