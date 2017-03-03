class Netflix < MovieCollection
	attr_accessor :balance

	def initialize(file)
		super(file)
		@balance = 0
	end

	def pay(amount)
		@balance += amount
	end

	def how_much?(title)
		@movies.select{|movie| movie.title == title}[0].price
	end

	def show(options = {})
		movies_after_filtering = []
		options.each_pair do |key, value|	
			movies_after_filtering << self.filter(key, value)
		end
		suitable_movies = movies_after_filtering.inject(:+)
		if suitable_movies.length == 0
			raise NameError, 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
		end
		movie_to_show = pick_movie_by_weight(suitable_movies)
		if @balance < movie_to_show.price
			raise StandardError, "Не хватает средств. Сейчас на балансе #{self.balance}, а данный фильм стоит #{movie_to_show.price}." 
		end
		movie_to_show.change_balance
		puts "Now showing #{movie_to_show.title}"	
		movie_to_show.description
	end

end