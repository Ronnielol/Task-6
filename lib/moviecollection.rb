require 'csv'

class MovieCollection
	def initialize(file)
		@movies = CSV.foreach(file, col_sep: '|', headers: %w{link title year country date 
			 genre length rating director actors}, force_quotes: 'false', converters: [:numeric]).map do |row|
			case row['year']
				when 1900..1944
					period = :ancient
					movie_class = AncientMovie
					price = 1
				when 1945..1967
					period = :classic
					movie_class = ClassicMovie
					price = 1.5
				when 1968..1999
					period = :modern
					movie_class = ModernMovie
					price = 3
			 	when 2000..Date.today.cwyear
					period =:new
					movie_class = NewMovie
					price = 5
				end
			movie_class.new(row["link"], row["title"], row["year"], row["country"],
										  row["date"], row["genre"], row["length"], row["rating"],
										  row["director"], row["actors"], self, period, price)
		end

	end

	private

		def movie_description(movie)
			puts 'Описание фильма:'
			case movie.class.to_s
			when 'AncientMovie'
				puts "#{movie.title} - старый фильм #{movie.year}"
			when 'ClassicMovie' 
				puts "#{movie.title} - классический фильм, #{movie.director} (ещё #{self.stats(:director)[movie.director.to_s].to_i - 1} его фильмов в спике)"
			when 'ModernMovie'
				puts "#{movie.title} - современное кино: играют #{movie.actors.join(", ")}"
			when 'NewMovie'
				puts "#{movie.title} - новинка, вышло #{Date.today.cwyear - movie.year} лет назад"
			end
		end

		def pick_movie_by_weight(movies)
			movies.sort_by{|movie| rand * movie.rating}[0]
		end

end