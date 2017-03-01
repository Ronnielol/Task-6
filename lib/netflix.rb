class Netflix < MovieCollection
	attr_reader :balance

	def initialize(file)
		super(file)
		@balance = 0
	end

	def pay(amount)
		@balance += amount
	end

	def how_much?(title)
		@movies.select{|movie| movie.title == title}.map{|movie| puts movie.price}
	end

	def show(options = {})
		movies = []
		options.each_pair do |key, value|
			if value.class.to_s == 'Symbol'
				movies << @movies.select{|movie| movie.send(key) == value}
			else
				movies << @movies.select{|movie| movie.send(key).include? value}
			end
		end
		suitable_movies = movies.reject{|array| array.nil?}.inject(:+)
		movie_to_show = pick_movie_by_weight(suitable_movies)
		if @balance < movie_to_show.price
			raise StandardError, 'Не хватает денег'
		end
		case movie_to_show.class.to_s
			when 'AncientMovie'
				@balance -= 1
			when 'ClassicMovie' 
				@balance -= 1.5
			when 'ModernMovie'
				@balance -= 3
			when 'NewMovie'
				@balance -= 5
			end
		puts "Now showing #{movie_to_show.title}"	
		movie_description(movie_to_show)
	end

end