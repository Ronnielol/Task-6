class Netflix < MovieCollection
	attr_accessor :balance

	def initialize(file)
		super
		@balance = 0
	end

	def pay(amount)
		if amount <= 0 
			raise StandardError, "Нельзя пополнить счет на 0 или отрициательное значение."
		end
		@balance += amount
	end

	def how_much?(title)
		@movies.detect{|movie| movie.title == title}.price
	end

	def change_balance(movie_price)
		@balance -= movie_price
	end

	def show(options = {})
		suitable_movies = self.filter(options)
		if suitable_movies.empty?
			raise RuntimeError, 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
		end
		movie_to_show = pick_movie_by_weight(suitable_movies)
		if @balance < movie_to_show.price
			raise StandardError, "Не хватает средств. Сейчас на балансе #{self.balance}, а данный фильм стоит #{movie_to_show.price}." 
		end
		change_balance(movie_to_show.price)
		puts "Now showing #{movie_to_show.title}"	
		movie_to_show.description
	end

end