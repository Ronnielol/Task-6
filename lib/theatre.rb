class Theatre < MovieCollection

	def initialize(file)
		super(file)
		@morning_movies = @movies.select{|movie| movie.class.to_s == 'AncientMovie'}
		@comedies_and_adventure = @movies.select{|movie| movie.genre.include? 'Comedy'} + @movies.select{|movie| movie.genre.include? 'Adventure'}
		@dramas_and_horrors = @movies.select{|movie| movie.genre.include? 'Drama'} + @movies.select{|movie| movie.genre.include? 'Horror'}
		
	end

	def show(time)
		case time.to_i
		when 6..12
			movies_to_show = @morning_movies
		when 12..17
			movies_to_show = @comedies_and_adventure
		when 18..23
			movies_to_show = @dramas_and_horrors
		end
		movie_to_show = pick_movie_by_weight(movies_to_show)
		puts "Now showing #{movie_to_show.title}"
		movie_description(movie_to_show)
	end

	def when?(movie_title)
		selected_movie = @movies.select{|movie| movie.title.include? movie_title}
		if @morning_movies.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают утром с 6 до 11."
		elsif @comedies_and_adventure.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают днем с 12 до 17"
		elsif @dramas_and_horrors.include? selected_movie[0]
			puts "Фильм #{movie_title} показывают вечером с 18 до 23" 	
		else 
			puts "В кинотеатре этот фильм не показывают."		
		end
	end

end