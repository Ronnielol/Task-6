class Theatre < MovieCollection

	SCHEDULE_TIME = {morning: (6..11), afternoon: (12..17), evening: (18..23)}
	MORNING_SETTINGS = {class: AncientMovie}
	AFTERNOON_SETTINGS = [{genre: 'Adventure'},{genre: 'Comedy'}]
	EVENING_SETTINGS = [{genre: 'Drama'}, {genre: 'Horror'}]

	def initialize(file)
		super(file)
		@morning_movies = self.filter(MORNING_SETTINGS.keys.first, MORNING_SETTINGS.values.first)
		@afternoon_movies = self.filter(AFTERNOON_SETTINGS[0].keys.first, AFTERNOON_SETTINGS[0].values.first) + self.filter(AFTERNOON_SETTINGS[1].keys.first, AFTERNOON_SETTINGS[1].values.first)
		@evening_movies = self.filter(EVENING_SETTINGS[0].keys.first, EVENING_SETTINGS[0].values.first) + self.filter(EVENING_SETTINGS[1].keys.first, EVENING_SETTINGS[1].values.first)
	end

	def show(time)
		case time.to_i
		when SCHEDULE_TIME[:morning]
			movies_to_show = @morning_movies
		when SCHEDULE_TIME[:afternoon]
			movies_to_show = @afternoon_movies
		when SCHEDULE_TIME[:evening]
			movies_to_show = @evening_movies
		end
		movie_to_show = pick_movie_by_weight(movies_to_show)
		puts "Now showing #{movie_to_show.title}"
		movie_to_show.description
	end

	def when?(movie_title)
		selected_movie = self.filter(:title, movie_title)
		movies_in_schedule = [@morning_movies, @afternoon_movies, @evening_movies]
		if !movies_in_schedule.inject(:+).include? selected_movie[0]
			puts "В кинотеатре данный фильм не показывают"
		end
		movies_in_schedule.each do |day_part|
			if day_part.include? selected_movie[0]
				print "Фильм #{movie_title} показывают "
				case day_part
				when @morning_movies
					puts "утром с #{SCHEDULE_TIME[:morning].first} до #{SCHEDULE_TIME[:morning].last}."	
				when @afternoon_movies
					puts "днем с #{SCHEDULE_TIME[:afternoon].first} до #{SCHEDULE_TIME[:afternoon].last}."
				when @evening_movies
					puts "вечером с #{SCHEDULE_TIME[:evening].first} до #{SCHEDULE_TIME[:evening].last}"	
				end
			end
		end
	end

end