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

end

class AncientMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 1
	end

	def description
		super
		return "старый фильм #{self.year}"
	end

end

class ClassicMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 1.5
	end

	def description
		super
		return "классический фильм #{director} (ещё #{collection.stats(:director)[director] - 1} его фильмов в списке)"
	end

end

class ModernMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 3
	end

	def description
		super
		return "современное кино: играют #{self.actors.join(", ")}"
	end

end

class NewMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 5
	end

	def description
		super
		return "новинка, вышло #{Date.today.cwyear - self.year.to_i} лет назад"
	end

end