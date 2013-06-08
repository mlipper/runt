
require 'date'
require 'runt'

include Runt

a_monday = Date.new(2013,5,13)                  # Monday, May 13 - has "day-level" precision
a_wednesday = DateTime.new(2013,5,15,8,45)      # Wednesday, May 15 at 8:45am - has "minute-level" precision

monday_expr = DIWeek.new(Mon)                   # Matches any Monday
monday_expr.include?(a_monday)                  # => true 
monday_expr.include?(a_wednesday)               # => false 

wednesday_expr = DIWeek.new(Wed)                # Matches any Wednesday
wednesday_expr.include?(a_monday)               # => false 
wednesday_expr.include?(a_wednesday)            # => true 

#
# Use an "OR" between two expressions
#
mon_or_wed_expr = monday_expr | wednesday_expr  # Matches any Monday OR any Wednesday
mon_or_wed_expr.include?(a_monday)              # => true
mon_or_wed_expr.include?(a_wednesday)           # => true

daily_8_to_11_expr =REDay.new(8,00,11,00,false) # Matches from 8am to 11am on ANY date. 
                                                # The 'false' argument says not to auto-match 
                                                # expressions of lesser precision.

at_9 = DateTime.new(2013,5,12,9,0)              # Sunday, May 12 at 9:00am
daily_8_to_11_expr.include?(at_9)               # => true 
#
# On the next line, the given Date instance is "promoted" to the minute-level precision 
# required by the temporal expression so the time component defaults to 00:00
#
daily_8_to_11_expr.include?(a_monday)           # => false 

#
# Use an "AND" between two expressions to match
#
#   (Monday OR Wednesday) AND (8am to 11am)
#
mon_or_wed_8_to_11_expr = mon_or_wed_expr & daily_8_to_11_expr

mon_or_wed_8_to_11_expr.include?(a_monday)      # => false - 00:00 is not between 8:00 and 11:00
mon_or_wed_8_to_11_expr.include?(at_9)          # => false - on Sunday
mon_or_wed_8_to_11_expr.include?(a_wednesday)   # => true - a Wednesday at 8:45

