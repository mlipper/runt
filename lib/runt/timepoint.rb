#!/usr/bin/env ruby

require 'date'
require 'runt'


module Runt

  # :title:TimePoint
  # == TimePoint
  #
  #
  # Based the <tt>pattern</tt>[http://martinfowler.com/ap2/timePoint.html] by Martin Fowler.
  #
  #
  # Author:: Matthew Lipper
  class TimePoint < DateTime
    include DatePrecision

    attr_accessor :date_precision

    class << self
      alias_method :old_civil, :civil

      def civil(*args)
        if(args[0].instance_of?(DatePrecision::Precision))
          precision = args.shift
        else
          return TimePoint::second(*args)
        end
        _civil = old_civil(*args)
        _civil.date_precision = precision
        _civil
      end
    end

    class << self; alias_method :new, :civil end

      def + (n)
        raise TypeError, 'expected numeric' unless n.kind_of?(Numeric)
        case @date_precision
        when YEAR then
          return DatePrecision::to_p(TimePoint::civil(year+n,month,day),@date_precision)
        when MONTH then
          current_date = self.class.to_date(self)
          return DatePrecision::to_p((current_date>>n),@date_precision)
        when DAY_OF_MONTH then
          return new_self_plus(n)
        when HOUR_OF_DAY then
          return new_self_plus(n){ |n| n = (n*(1.to_r/24) ) }
        when MINUTE then
          return new_self_plus(n){ |n| n = (n*(1.to_r/1440) ) }
            when SECOND then
          return new_self_plus(n){ |n| n = (n*(1.to_r/86400) ) }
      end
    end

    def - (x)
      case x
        when Numeric then
          return self+(-x)
        #FIXME!!
        when Date;    return @ajd - x.ajd
      end
      raise TypeError, 'expected numeric or date'
    end

    def <=> (other)
      result = nil
      if(other.respond_to?("date_precision") && other.date_precision>@date_precision)
        result = super(DatePrecision::to_p(other,@date_precision))
      else
        result = super(other)
      end
      puts "#{self.to_s}<=>#{other.to_s} => #{result}" if $DEBUG
      result
    end

    def new_self_plus(n)
      if(block_given?)
        n=yield(n)
      end
      return DatePrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
    end

    def TimePoint.to_date(timepoint)
      if( timepoint.date_precision > DatePrecision::DAY_OF_MONTH) then
        DateTime.new(timepoint.year,timepoint.month,timepoint.day,timepoint.hour,timepoint.min,timepoint.sec)
      end
      return Date.new(timepoint.year,timepoint.month,timepoint.day)
    end

    def TimePoint.year(yr,*ignored)
      TimePoint.civil(YEAR, yr, MONTH.min_value, DAY_OF_MONTH.min_value  )
    end

    def TimePoint.month( yr,mon,*ignored )
      TimePoint.civil(MONTH, yr, mon, DAY_OF_MONTH.min_value  )
    end

    def TimePoint.day_of_month( yr,mon,day,*ignored )
      TimePoint.civil(DAY_OF_MONTH, yr, mon, day )
    end

    def TimePoint.hour_of_day( yr,mon,day,hr=HOUR_OF_DAY.min_value,*ignored )
      TimePoint.civil(HOUR_OF_DAY, yr, mon, day,hr,MINUTE.min_value, SECOND.min_value)
    end

    def TimePoint.minute( yr,mon,day,hr=HOUR_OF_DAY.min_value,min=MINUTE.min_value,*ignored )
      TimePoint.civil(MINUTE, yr, mon, day,hr,min, SECOND.min_value)
    end

    def TimePoint.second( yr,mon,day,hr=HOUR_OF_DAY.min_value,min=MINUTE.min_value,sec=SECOND.min_value,*ignored )
      TimePoint.civil(SECOND, yr, mon, day,hr,min, sec)
    end

    def TimePoint.millisecond( yr,mon,day,hr,min,sec,ms,*ignored )
      raise "Not implemented yet."
    end

    def TimePoint.default(*args)
      TimePoint.civil(DEFAULT, *args)
    end

  end

end
