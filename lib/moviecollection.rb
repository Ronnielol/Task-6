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

	def filter(options)
		values_array = []
		options.map{ |key, values|
			if !values.is_a? Array
				values_array << values
			else 
				values_array = values
			end
			if values_array.map(&:class).include? Symbol
				values_array.map{|value| 
						@movies.select{|movie| movie.send(key) == value}
					}.inject(:+)
			else
				values_array.map{|value| 
						@movies.select{|movie| movie.send(key).include? value}
					}.inject(:+)
			end
		}.inject(:+).uniq
	end

	private

		def pick_movie_by_weight(movies)
			movies.sort_by{|movie| rand * movie.rating}[0]
		end

end