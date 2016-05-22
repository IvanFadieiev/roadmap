=begin
	сделать возможным такой синтаксис
	case date
	when Today
	  puts 'it is today'
	when Yesterday
	  puts 'I was yesterday'
	when Tomorrow
	  puts 'It will be tomorrow'
	end
=end
require 'date'

class Today
	def initialize(date)
		@today = date
	end
end

class Yesterday
	def initialize(date)
		@yesterday = (date)
	end
end

class Tomorrow
	def initialize(date)
		@tomorrow = date
	end
end


p "пожалуйста напишите ближайшую дату ( в формате yyyy/mm/dd ):"

m = gets.chomp.split("/")
yyyy = m[0].to_i
mm   = m[1].to_i
dd   = m[2].to_i
n = Date.new(yyyy,mm,dd)

case n
	when Date.today
		date = Today.new(n)
	when Date.today.prev_day
		date = Yesterday.new(n)
	when Date.today.next_day
		date = Tomorrow.new(n)
	else
		p "это возможно недалекое будущее... ну или прошлое))"
end

case date
	when Today
	  puts 'It is today'
	when Yesterday
	  puts 'It was yesterday'
	when Tomorrow
	  puts 'It will be tomorrow'
end