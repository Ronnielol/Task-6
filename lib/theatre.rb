class Theatre < MovieCollection

	FILTERS = {
		morning: {time: (6..11), period: {period: :ancient}},
		afternoon: {time: (12..17), genre: {genre:['Comedy', 'Adventure']}},
		evening: {time: (18..23), genre: {genre:['Drama', 'Horror']}}
	}

	def initialize(file)
		super(file)
		@schedule = {FILTERS.keys[0] => self.filter(FILTERS[:morning][:period]), 
					 FILTERS.keys[1] => self.filter(FILTERS[:afternoon][:genre]),
					 FILTERS.keys[2] => self.filter(FILTERS[:evening][:genre])}
	end

	def show(time)
		case time.to_i
		when FILTERS[:morning][:time]
			movies_to_show = @schedule[FILTERS.keys[0]]
		when FILTERS[:afternoon][:time]
			movies_to_show = @schedule[FILTERS.keys[1]]
		when FILTERS[:evening][:time]
			movies_to_show = @schedule[FILTERS.keys[2]]
		end
		movie_to_show = pick_movie_by_weight(movies_to_show)
		puts "Now showing #{movie_to_show.title}"
		movie_to_show.description
	end

	def when?(movie_title)
		selected_movie = self.filter(title: movie_title)[0]
		in_schedule = false
		@schedule.each do |key, value| 
			if value.include? selected_movie
				puts "#{selected_movie.title} показывают с #{FILTERS[key][:time].first} до #{FILTERS[key][:time].last}"
				in_schedule = true
			end
		end
		if !in_schedule
			puts "Данный фильм в кинотеатре не показывают."
		end
	end

end