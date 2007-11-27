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
    include DPrecision

    attr_accessor :date_precision

    class << self
      alias_method :old_civil, :civil

      def civil(*args)
	precision=nil
        if(args[0].instance_of?(DPrecision::Precision))
          precision = args.shift
        else
          return PDate::sec(*args)
        end
        _civil = old_civil(*args)
        _civil.date_precision = precision
        _civil
      end
    end

    class << self; alias_method :new, :civil end

    def include?(expr)
      eql?(expr)
    end

    def + (n)
      raise TypeError, 'expected numeric' unless n.kind_of?(Numeric)
      case @date_precision
      when YEAR then
	return DPrecision::to_p(PDate::civil(year+n,month,day),@date_precision)
      when MONTH then
	current_date = self.class.to_date(self)
	return DPrecision::to_p((current_date>>n),@date_precision)
      when DAY then
	return new_self_plus(n)
      when HOUR then
	return new_self_plus(n){ |n| n = (n*(1.to_r/24) ) }
      when MIN then
	return new_self_plus(n){ |n| n = (n*(1.to_r/1440) ) }
      when SEC then
	return new_self_plus(n){ |n| n = (n*(1.to_r/86400) ) }
      when MILLI then
	return self
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
      result = super(DPrecision::to_p(other,@date_precision))
    else
      result = super(other)
    end
    #puts "#{self.to_s}<=>#{other.to_s} => #{result}" if $DEBUG
    result
  end

  def new_self_plus(n)
    if(block_given?)
      n=yield(n)
    end
    return DPrecision::to_p(self.class.new0(@ajd + n, @of, @sg),@date_precision)
  end

  def PDate.to_date(pdate)
    if( pdate.date_precision > DPrecision::DAY) then
      DateTime.new(pdate.year,pdate.month,pdate.day,pdate.hour,pdate.min,pdate.sec)
    end
    return Date.new(pdate.year,pdate.month,pdate.day)
  end

  def PDate.year(yr,*ignored)
    PDate.civil(YEAR, yr, MONTH.min_value, DAY.min_value  )
  end

  def PDate.month( yr,mon,*ignored )
    PDate.civil(MONTH, yr, mon, DAY.min_value  )
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

  #
  # Custom dump which preserves DatePrecision   
  # 
  # Author:: Jodi Showers
  #
  def marshal_dump
    [date_precision, ajd, sg, of]
  end

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
