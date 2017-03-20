class Movie
	attr_reader :link, :title, :year, :country, :date, 
			 	  :genre, :length, :rating, :director, :actors, :collection, :price, :period

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@date = Date.parse(date) if date.to_s.length > 7
			
		@link, @title, @year, @country, @genre, @length, @rating, @director, @actors, @collection = link, title, year, country, 
			 	   genre.split(","), length, rating, director, actors.split(","), collection
		@period = self.class.to_s.gsub("Movie", "").downcase.to_sym
	end

	def self.create(row, collection)
		case row['year']
			when 1900..1944
				movie_class = AncientMovie
			when 1945..1967
				movie_class = ClassicMovie
			when 1968..1999
				movie_class = ModernMovie
		 	when 2000..Date.today.cwyear
				movie_class = NewMovie
			else
				raise RuntimeError, "У фильма неподходящий год. В базе могут быть только фильмы, снятые с 1900 года по настоящий."
			end
		movie_class.new(row["link"], row["title"], row["year"], row["country"],
										  row["date"], row["genre"], row["length"], row["rating"],
										  row["director"], row["actors"], collection)
	end

	def has_genre?(genre)
	    if !@collection.genre_exists?(genre) 
	      raise ArgumentError, 'Аргумент задан с ошибкой, либо такого жанра не существует.'
	   	end
	   	@genre.include? genre
  	end

  	def description
		return "#{self.title} - "
	end

	def match_filters?(options)
		movie_info = [genre, period].flatten
		options_value = options.values[0]
		if options_value.is_a?(Symbol)
			movie_info.include? options_value
		elsif options_value.is_a?(Array) 
			!(options_value & movie_info).empty?
		end
	end

end

class AncientMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 1
	end

	def description
		super
		"старый фильм #{year}"
	end

end

class ClassicMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 1.5
	end

	def description
		super
		"классический фильм #{director} (ещё #{collection.stats(:director)[director] - 1} его фильмов в списке)"
	end

end

class ModernMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 3
	end

	def description
		super
		"современное кино: играют #{self.actors.join(", ")}"
	end

end

class NewMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 5
	end

	def description
		super
		"новинка, вышло #{Date.today.cwyear - self.year.to_i} лет назад"
	end

end