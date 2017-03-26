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
		_,period_settings = PERIODS.detect{ |period, value| value[:years] === row['year']}
		if period_settings.nil?
			raise RuntimeError, "У фильма неподходящий год. В базе могут быть только фильмы, снятые с 1900 года по настоящий."
		end
		movie_class = period_settings[:movie_class] 
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

	def matches?(filters)
		filters.any? { |filter_name, filter_value| match_filter?(filter_name, filter_value) }
	end

	def match_filter?(filter_name, filter_value)
  		value = send(filter_name)
  		value.is_a?(Array) ? value.any? { |v| value_match?(v, filter_value) } : value_match?(value, filter_value)
	end

	def value_match?(value, filter_value)
  		filter_value.is_a?(Array) ? filter_value.any? { |fv| fv === value } : filter_value === value
	end

end

class AncientMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 1
	end

	def description
		"#{title} - старый фильм #{year}"
	end

end

class ClassicMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 1.5
	end

	def description
		"#{title} - классический фильм #{director} (ещё #{collection.stats(:director)[director] - 1} его фильмов в списке)"
	end

end

class ModernMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 3
	end

	def description
		"#{title} - современное кино: играют #{actors.join(", ")}"
	end

end

class NewMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super
		@price = 5
	end

	def description
		"#{title} - новинка, вышло #{Date.today.cwyear - year.to_i} лет назад"
	end

end

PERIODS = {
		ancient: { years: 1900..1944, movie_class: AncientMovie },
		classic: { years: 1945..1967, movie_class: ClassicMovie },
		modern: { years: 1968..1999, movie_class: ModernMovie },
		new: { years: 2000..Date.today.cwyear, movie_class: NewMovie }
	}