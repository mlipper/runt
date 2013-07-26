# Sugar Tutorial

* This tutorial assumes you are familiar with use of the Runt API to create temporal expressions. If you're unfamiliar with how and why to write temporal expressions, take a look at the temporal expression [tutorial](tutorial_te.md).

* Starting with version 0.7.0, Runt provides some syntactic sugar for creating temporal expressions. Runt also provides a builder class for which can be used to create expressions in a more readable way than simply using `:new`.

First, let's look at some of the new shorcuts for creating individual expressions. If you look at the `lib/runt/sugar.rb` file you find that the `Runt` module has been re-opened and some nutty stuff happens when `:method_missing` is called.

For example, if you've included the `Runt` module, you can now create a `DIWeek` expression by calling a method whose name matches the following pattern:

```
/^(sunday|monday|tuesday|wednesday|thursday|friday|saturday)$/
```

So

    tuesday

is equivalent to

    DIWeek.new(Tuesday)

Here's a quick summary of patterns and the expressions they create.

### REDay

**regex**:   `/^daily_(d{1,2})_(d{2})([ap]m)*to*(d{1,2})_(d{2})([ap]m)$/`

**example**: `daily_8_30am_to_10_00pm`

**action**:  `REDay.new(8,30,22,00)`


### REWeek

**regex**:   `/^weekly_(sunday|monday|tuesday|wednesday|thursday|friday|saturday)_to_(sunday|monday|tuesday|wednesday|thursday|friday|saturday)$/`

**example**: `weekly_wednesday_to_friday`

**action**:  `REWeek.new(Wednesday, Friday)`


### REMonth

**regex**:   `/^monthly_(d{1,2})(?:st|nd|rd|th)_to_(d{1,2})(?:st|nd|rd|th)$/`

**example**: `monthly_2nd_to_24th`

**action**:  `REMonth.new(2,24)` 


### REYear

**regex**:   `/^yearly_(january|february|march|april|may|june|july|august|september|october|november|december)_(d{1,2})_to_(january|february|march|april|may|june|july|august|september|october|november|december)_(d{1,2})`

**example**: `yearly_may_31_to_september_1`

**action**:  `REYear.new(May,31,September,1)`


### DIWeek

**regex**:   `/^(sunday|monday|tuesday|wednesday|thursday|friday|saturday)$/`

**example**: `friday`

**action**:  `DIWeek.new(Friday)`


### DIMonth

**regex**:   `/^(first|second|third|fourth|last|second_to_last)_(sunday|monday|tuesday|w ednesday|thursday|friday|saturday)$/`

**example**: `last_friday`

**action**:  `DIMonth.new(Last,Friday)`


There are also other methods defined (not via `:method_missing`) which provide shortcuts:

### AfterTE

**method**:  `after(date, inclusive=false)`

**action**:  `AfterTE.new(date, inclusive=false)`


### BeforeTE

**method**:  `before(date, inclusive=false)`

**action**:  `BeforeTE.new(date, inclusive=false)`


Now let's look at the new `ExpressionBuilder` class. This class uses some simple methods and `instance_eval` to allow one to create composite temporal expressions in a more fluid style than `:new` and friends. The idea is that you define a block where method calls add to a composite expression using either "and", "or", or "not".

```ruby
# Create a new builder
d = ExpressionBuilder.new

# Call define with a block
expression = d.define do
  on REDay.new(8,45,9,30)       
  on DIWeek.new(Friday)              # "And"
  possibly DIWeek.new(Saturday)      # "Or"
  except DIMonth.new(Last, Friday)   # "Not"
end

# expression = "Daily 8:45am to 9:30 and Fridays or Saturday except not the last Friday of the month"
```

Hmmm, this is not really an improvement over

```ruby
REDay.new(8,45,9,30) & DIWeek.new(Friday) | DIWeek.new(Saturday) - DIMonth.new(Last, Friday)
```

I know, let's try the new constructor aliases defined above!

```ruby
expression = d.define do
  on daily_8_45am_to_9_30am
  on friday
  possibly saturday
  except last_friday
end
```

Much better, except "on daily..." seems  a little awkward. We can use `:occurs` which is aliased to `:on` for just such a scenario.

```ruby
expression = d.define do
  occurs daily_8_45am_to_9_30am
  on friday
  possibly saturday
  except last_friday
end
```

ExpressionBuilder creates expressions by evaluating a block passed to the `:define` method. From inside the block, methods `:occurs`, `:on`, `:every`, `:possibly`, and `:maybe` can be called with a temporal expression which will be added to a composite expression as follows:

**:on**        creates an "and" (`&`)

**:possibly**  creates an "or" (`|`)

**:except**    creates a "not" (`-`)

**:every**     alias for `:on` method

**:occurs**    alias for `:on` method

**:maybe**     alias for `:possibly` method 


Of course it's easy to open the builder class and add you own aliases if the ones provided don't work for you:

```ruby
class ExpressionBuilder
  alias_method :potentially, :possibly
  # etc....
end
```

If there are shortcuts or macros that you think others would find useful, send in a pull request.


*See Also:*

* Temporal Expressions [tutorial](tutorial_te.md)
* Schedule [tutorial](tutorial_schedule.md)
