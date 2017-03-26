require 'csv'

class MovieCollection

	HEADERS = %w{link title year country date 
			 genre length rating director actors}

	def initialize(file)
		@movies = CSV.foreach(file, col_sep: '|', headers: HEADERS, force_quotes: 'false', converters: [:numeric]).map{|row| Movie.create(row, self)}
	end

	def stats(arg)
		@movies
			.map(&arg)
			.compact
			.each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
	end

	def filter(filters)
		@movies.select{|movie| movie.matches?(filters)}
	end

	private

		def pick_movie_by_weight(movies)
			movies.sort_by{|movie| rand * movie.rating}[0]
		end

end