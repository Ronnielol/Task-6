class Movie
	attr_reader :link, :title, :year, :country, :date, 
			 	  :genre, :length, :rating, :director, :actors, :collection, :period, :price

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection, period, price)
		@date = Date.parse(date) if date.to_s.length > 7
			
		@link, @title, @year, @country, @genre, @length, @rating, @director, @actors, @collection, @period, @price  = link, title, year, country, 
			 	   genre.split(","), length, rating, director, actors.split(","), collection, period, price
	end

	def has_genre?(arg)
	    if !@collection.genre_exists?(arg) 
	      raise ArgumentError, 'Аргумент задан с ошибкой, либо такого жанра не существует.'
	   	end
	   	@genre.include? arg
  	end
end

class AncientMovie < Movie
end

class ClassicMovie < Movie
end

class ModernMovie < Movie
end

class NewMovie < Movie
end