#Написать класс Sundays который будет возвращать энемератор каждая итерация 
#которго возвращает дату следующего воскресенья, начинать нужно с текущего
#или билжайшего следующего воскресенья
#Sundays.lazy.map(&:tomorrow).take(5).to_a должно нам вернуть 5 понедельников

class Sunday < Enumerator
  require 'date'
  require 'active_support/core_ext/date/calculations'
  require 'byebug'

  def self.lazy  
    year = Date.today.year
    current_month = Date.today.month
    start = Date.today.day
    enum = Enumerator.new do |yielder|
      current_month.upto(12).each do |mon|
        if mon == current_month
          start_day = start
        else
          start_day = 1
        end
        days = Sunday.month_days(mon)
        start_day.upto(days).each do |days|
        day =  Date.new(year,mon,days)
            if day.sunday?
              yielder << day
            end
          end
        end
      end
    enum.lazy
  end

# задаем количество дней в месяцах
  def self.month_days(month,year=Date.today.year)
    mdays = [nil,31,28,31,30,31,30,31,31,30,31.30,31]
    mdays[2] = 29 if Date.leap?(year)
    mdays[month]
  end
end


p "--------------------------------------------------------------------"
p "Даты ближайших воскресений! сколько воскресений хотите увидеть?"
n = gets.chomp.to_i
p Sunday.lazy.map{ |a| a }.take(n).to_a
p "--------------------------------------------------------------------"
p "Даты ближайших понедельников! сколько понедельников хотите увидеть?"
n = gets.chomp.to_i
p Sunday.lazy.map(&:tomorrow).take(n).to_a
p "--------------------------------------------------------------------"