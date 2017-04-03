class Theatre < MovieCollection

	include Task7::Cashbox

	SCHEDULE = {
		morning: {time: (6..11), filters: {period: :ancient}, price: 3},
		afternoon: {time: (12..17), filters: {genre:['Comedy', 'Adventure']}, price: 5},
		evening: {time: (18..23), filters: {genre:['Drama', 'Horror']}, price: 10}
	}

	def initialize(file)
		super
		initialize_balance
	end

	def show(time)
		check_time(time)
		period = SCHEDULE.detect{ |k, v| v[:time].include?(time.to_i)}.first
		movie_to_show = fetch_movie(period)
		puts "Now showing #{movie_to_show.title}"
		movie_to_show.description
	end

	def when?(movie_title)
		selected_movie = self.filter(title: movie_title)[0]
		movie_is_presented?(selected_movie)
		daytime,_ = SCHEDULE.detect{ |name, options| selected_movie.matches?(options[:filters])}
		"#{selected_movie.title} показывают с #{SCHEDULE[daytime][:time].first} до #{SCHEDULE[daytime][:time].last}"
	end

	def cash
		balance
	end

	def buy_ticket(movie_title)
		selected_movie = self.filter(title: movie_title)[0]
		movie_is_presented?(selected_movie)
		_,options = SCHEDULE.detect{ |name, options| selected_movie.matches?(options[:filters]) }
		movie_price = options[:price]
		replenish_balance(movie_price)
		"Вы купили билет на #{selected_movie.title}"
	end

	
	private 

		def fetch_movie(period)
			pick_movie_by_weight(self.filter(SCHEDULE[period][:filters]))
		end

		def check_time(time)
			if !SCHEDULE.map{ |k, v| v[:time].to_a}.flatten.include?(time.to_i)
				raise RuntimeError, "Наш кинотеатр работает с #{SCHEDULE[:morning][:time].first} до #{SCHEDULE[:evening][:time].last}. Вы выбрали время #{time}."
			end
		end

		def movie_is_presented?(movie)
			if movie.nil?
				raise RuntimeError, 'Не найдено подходящих фильмов. Проверьте правильность ввода.'
			end
		end

end