require 'csv'

class MovieCollection
	def initialize(file)
		@movies = CSV.foreach(file, col_sep: '|', headers: %w{link title year country date 
			 genre length rating director actors}, force_quotes: 'false', converters: [:numeric]).map do |row|
			case row['year']
				when 1900..1944
					movie_class = AncientMovie
				when 1945..1967
					movie_class = ClassicMovie
				when 1968..1999
					movie_class = ModernMovie
			 	when 2000..Date.today.cwyear
					movie_class = NewMovie
				end
			movie_class.new(row["link"], row["title"], row["year"], row["country"],
										  row["date"], row["genre"], row["length"], row["rating"],
										  row["director"], row["actors"], self)
		end

	end

	def stats(arg)
		@movies
			.select(&arg)
			.map(&arg)
			.each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
	end

	def filter(key, value)
		if value.is_a? Symbol
			@movies.select{|movie| movie.send(key) == value}
		elsif key == :class
			@movies.select{|movie| movie.is_a? value}
		else
			@movies.select{|movie| movie.send(key).include? value}
		end
	end

	private

		def pick_movie_by_weight(movies)
			movies.sort_by{|movie| rand * movie.rating}[0]
		end

end