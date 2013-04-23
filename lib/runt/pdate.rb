#!/usr/bin/env ruby

require 'date'
require 'runt'


module Runt


  # :title:PDate
  # == PDate
  # Date and DateTime with explicit precision.
  #
  # Based the <tt>pattern</tt>[http://martinfowler.com/ap2/timePoint.html] by Martin Fowler.
  #
  #
  # Author:: Matthew Lipper
  class PDate < DateTime
	include Comparable
    include DPrecision

    attr_accessor :date_precision

    class << self

      def civil(*args)
        precision=nil
        if(args[0].instance_of?(DPrecision::Precision))
          precision = args.shift
        else
          return PDate::sec(*args)
        end
        pdate = super(*args)
        pdate.date_precision = precision
        pdate
      end
      
      def parse(*args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        pdate = super(*args)
        pdate.date_precision = opts[:precision] || opts[:date_precision]
        pdate
      end

	  alias_method :new, :civil
      
    end

    def include?(expr)
      eql?(expr)
    end

    def + (n)
      raise TypeError, 'expected numeric' unless n.kind_of?(Numeric)
	  ndays = n
      case @date_precision
      when YEAR then
        return DPrecision::to_p(PDate::civil(year+n,month,day),@date_precision)
      when MONTH then
        return DPrecision::to_p((self.to_date>>n),@date_precision)
      when WEEK then
        ndays = n*7	
      when DAY then
        ndays = n
      when HOUR then
        ndays = n*(1.to_r/24)
      when MIN then
        ndays = n*(1.to_r/1440)
      when SEC then
        ndays = n*(1.to_r/86400)
      when MILLI then
        ndays = n*(1.to_r/86400000)
      end
	  DPrecision::to_p((self.to_date + ndays),@date_precision)
    end

    def - (x)
      case x
      when Numeric then
        return self+(-x)
      when Date then
	 	return super(DPrecision::to_p(x,@date_precision))
      end
      raise TypeError, 'expected numeric or date'
    end

    def <=> (other)
      result = nil
	  raise "I'm broken #{self.to_s}" if @date_precision.nil?
      if(!other.nil? && other.respond_to?("date_precision") && other.date_precision>@date_precision)
        result = super(DPrecision::to_p(other,@date_precision))
      else
        result = super(other)
      end
      puts "self<#{self.to_s}><=>other<#{other.to_s}> => #{result}" if $DEBUG
      result
    end

    def succ
	  result = self + 1
	end

    def to_date_time
      DateTime.new(self.year,self.month,self.day,self.hour,self.min,self.sec)
    end
    
    def to_date
      (self.date_precision > DPrecision::DAY) ? self.to_date_time : Date.new(self.year, self.month, self.day)
    end


    def PDate.to_date(pdate)
      pdate.to_date
    end

    def PDate.year(yr,*ignored)
      PDate.civil(YEAR, yr, MONTH.min_value, DAY.min_value  )
    end

    def PDate.month( yr,mon,*ignored )
      PDate.civil(MONTH, yr, mon, DAY.min_value  )
    end

    def PDate.week( yr,mon,day,*ignored )
      #LJK: need to calculate which week this day implies,
      #and then move the day back to the *first* day in that week;
      #note that since rfc2445 defaults to weekstart=monday, I'm 
      #going to use commercial day-of-week
      raw = PDate.day(yr, mon, day)
      cooked = PDate.commercial(raw.cwyear, raw.cweek, 1)
      PDate.civil(WEEK, cooked.year, cooked.month, cooked.day)
    end

    def PDate.day( yr,mon,day,*ignored )
      PDate.civil(DAY, yr, mon, day )
    end

    def PDate.hour( yr,mon,day,hr=HOUR.min_value,*ignored )
      PDate.civil(HOUR, yr, mon, day,hr,MIN.min_value, SEC.min_value)
    end

    def PDate.min( yr,mon,day,hr=HOUR.min_value,min=MIN.min_value,*ignored )
      PDate.civil(MIN, yr, mon, day,hr,min, SEC.min_value)
    end

    def PDate.sec( yr,mon,day,hr=HOUR.min_value,min=MIN.min_value,sec=SEC.min_value,*ignored )
      PDate.civil(SEC, yr, mon, day,hr,min, sec)
    end

    def PDate.millisecond( yr,mon,day,hr,min,sec,ms,*ignored )
      PDate.civil(SEC, yr, mon, day,hr,min, sec, ms, *ignored)
      #raise "Not implemented yet."
    end

    def PDate.default(*args)
      PDate.civil(DEFAULT, *args)
    end

	#FIXME: marshall broken in 1.9
    #
    # Custom dump which preserves DatePrecision   
    # 
    # Author:: Jodi Showers
    #
    def marshal_dump
      [date_precision, ajd, start, offset]
    end

	#FIXME: marshall broken in 1.9
    #
    # Custom load which preserves DatePrecision   
    # 
    # Author:: Jodi Showers
    #
    def marshal_load(dumped_obj)
      @date_precision, @ajd, @sg, @of=dumped_obj
    end

  end
end
