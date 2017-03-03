class Theatre < MovieCollection

	SCHEDULE_TIME = {morning: (6..11), afternoon: (12..17), evening: (18..23)}
	#

	def initialize(file)
		super(file)
		@morning_movies = @movies.select{|movie| movie.class.to_s == 'AncientMovie'}
		@afternoon_movies = self.filter(:genre, 'Comedy') + self.filter(:genre, 'Adventure')
		@evening_movies = self.filter(:genre, 'Drama') + self.filter(:genre, 'Horror')
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
		if @morning_movies.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают утром с 6 до 11."
		elsif @afternoon_movies.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают днем с 12 до 17"
		elsif @evening_movies.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают вечером с 18 до 23" 	
		else 
			puts "В кинотеатре этот фильм не показывают."		
		end
	end

end