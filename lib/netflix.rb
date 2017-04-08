require_relative 'modules/cashbox_implementation'
using CashboxImplementation::MoneyHelper

class Netflix < MovieCollection

	extend CashboxImplementation::Cashbox

	attr_accessor :user_balance

	def initialize(file)
		super
		@user_balance = 0.to_money
	end

	def pay(amount)
		if amount <= 0 
			raise StandardError, "Нельзя пополнить счет на 0 или отрициательное значение."
		end
		@user_balance += amount.to_money
		self.class.replenish_balance(amount)
	end

	def how_much?(title)
		@movies.detect{|movie| movie.title == title}.price
	end

	def show(options = {})
		suitable_movies = self.filter(options)
		if suitable_movies.empty?
			raise RuntimeError, 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
		end
		movie_to_show = pick_movie_by_weight(suitable_movies)
		if @user_balance < movie_to_show.price.to_money
			raise StandardError, "Не хватает средств. Сейчас на балансе #{user_balance}, а данный фильм стоит #{movie_to_show.price}." 
		end
		@user_balance -= movie_to_show.price.to_money
		puts "Now showing #{movie_to_show.title}"	
		movie_to_show.description
	end

end