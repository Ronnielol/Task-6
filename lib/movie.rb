class Movie
	attr_reader :link, :title, :year, :country, :date, 
			 	  :genre, :length, :rating, :director, :actors, :collection, :price, :period

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@date = Date.parse(date) if date.to_s.length > 7
			
		@link, @title, @year, @country, @genre, @length, @rating, @director, @actors, @collection = link, title, year, country, 
			 	   genre.split(","), length, rating, director, actors.split(","), collection
	end

	def has_genre?(genre)
	    if !@collection.genre_exists?(genre) 
	      raise ArgumentError, 'Аргумент задан с ошибкой, либо такого жанра не существует.'
	   	end
	   	@genre.include? genre
  	end

  	def description
  		puts "Описание фильма:"
		print "#{self.title} - "
	end

	def change_balance
		self.collection.balance -= self.price
	end
end

class AncientMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 1
		@period = :ancient
	end

	def description
		super
		puts "старый фильм #{self.year}"
	end

end

class ClassicMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 1.5
		@period = :classic
	end

	def description
		super
		puts "классический фильм, #{self.director} (ещё #{self.collection.stats(:director)[self.director.to_s].to_i - 1} его фильмов в списке)"
	end

end

class ModernMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 3
		@period = :modern
	end

	def description
		super
		puts "современное кино: играют #{self.actors.join(", ")}"
	end

end

class NewMovie < Movie

	def initialize(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		super(link, title, year, country, date, 
			 	   genre, length, rating, director, actors, collection)
		@price = 5
		@period = :new
	end

	def description
		super
		puts "новинка, вышло #{Date.today.cwyear - self.year} лет назад"
	end

end