class Theatre < MovieCollection

	SCHEDULE = {
		morning: {time: (6..11), filters: {period: :ancient}},
		afternoon: {time: (12..17), filters: {genre:['Comedy', 'Adventure']}},
		evening: {time: (18..23), filters: {genre:['Drama', 'Horror']}}
	}

	def initialize(file)
		super(file)
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
		if selected_movie.nil?
			raise RuntimeError, 'Не найдено подходящих фильмов. Проверьте правильность ввода.'
		end
		daytime = SCHEDULE.detect{ |name, options| selected_movie.match_filters?(options[:filters])}[0]
		puts "#{selected_movie.title} показывают с #{SCHEDULE[daytime][:time].first} до #{SCHEDULE[daytime][:time].last}"
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

end