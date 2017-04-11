module Cinema

	module CashboxImplementation

		module MoneyHelper

			refine Numeric do
				def to_money
				 	Money.new(self*100, "USD")
				end
			end

		end

		module Cashbox

			using CashboxImplementation::MoneyHelper

			def replenish_balance(amount)
				@cashbox_balance = balance + amount.to_money
			end

			def balance
				@cashbox_balance ||= 0.to_money
			end

			def take(who)
				if who != 'Bank'
					raise RuntimeError, 'Вы не банк! Вызываем полицию!' 
				end
				@cashbox_balance = 0.to_money
				puts "Проведена инкассация."
			end

		end

	end

	module Collections

		class MovieCollection

			include Enumerable

			HEADERS = %w{link title year country date 
					 genre length rating director actors}

			def each(&block)
				@movies.each(&block)
			end

			def initialize(file)
				@movies = CSV.foreach(file, col_sep: '|', headers: HEADERS, force_quotes: 'false', converters: [:numeric]).map{|row| Cinema::Movies::Movie.create(row, self)}
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

	end

	module Movies

		class Movie

			attr_reader :link, :title, :year, :country, :date, 
					 	  :genre, :length, :rating, :director, :actors, :collection, :price, :period

			def initialize(link, title, year, country, date, 
					 	   genre, length, rating, director, actors, collection)
				@date = Date.parse(date) if date.to_s.length > 7
					
				@link, @title, @year, @country, @genre, @length, @rating, @director, @actors, @collection = link, title, year, country, 
					 	   genre.split(","), length, rating, director, actors.split(","), collection
				@period = self.class.to_s.gsub("Cinema::Movies::", "").gsub("Movie", "").downcase.to_sym
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

			using Cinema::CashboxImplementation::MoneyHelper

			def initialize(link, title, year, country, date, 
					 	   genre, length, rating, director, actors, collection)
				super
				@price = 1.to_money
			end

			def description
				"#{title} - старый фильм #{year}"
			end

		end

		class ClassicMovie < Movie

			using Cinema::CashboxImplementation::MoneyHelper

			def initialize(link, title, year, country, date, 
					 	   genre, length, rating, director, actors, collection)
				super
				@price = 1.5.to_money
			end

			def description
				"#{title} - классический фильм #{director} (ещё #{collection.stats(:director)[director] - 1} его фильмов в списке)"
			end

		end

		class ModernMovie < Movie

			using Cinema::CashboxImplementation::MoneyHelper

			def initialize(link, title, year, country, date, 
					 	   genre, length, rating, director, actors, collection)
				super
				@price = 3.to_money
			end

			def description
				"#{title} - современное кино: играют #{actors.join(", ")}"
			end

		end

		class NewMovie < Movie

			using Cinema::CashboxImplementation::MoneyHelper

			def initialize(link, title, year, country, date, 
					 	   genre, length, rating, director, actors, collection)
				super
				@price = 5.to_money
			end

			def description
				"#{title} - новинка, вышло #{Date.today.cwyear - year.to_i} лет назад"
			end

		end

		class Movie
			
			PERIODS = {
					ancient: { years: 1900..1944, movie_class: AncientMovie },
					classic: { years: 1945..1967, movie_class: ClassicMovie },
					modern: { years: 1968..1999, movie_class: ModernMovie },
					new: { years: 2000..Date.today.cwyear, movie_class: NewMovie }
				}

		end

	end	


	module Examples

		class Netflix < Cinema::Collections::MovieCollection

			using Cinema::CashboxImplementation::MoneyHelper

			extend CashboxImplementation::Cashbox

			attr_accessor :user_balance

			def initialize(file)
				super
				@user_balance = 0.to_money
			end

			def pay(amount)
				if amount <= 0 
					raise StandardError, "Нельзя пополнить счет на 0 или отрициательное значение."
				end
				@user_balance += amount.to_money
				self.class.replenish_balance(amount)
			end

			def how_much?(title)
				@movies.detect{|movie| movie.title == title}.price
			end

			def show(options = {})
				suitable_movies = self.filter(options)
				if suitable_movies.empty?
					raise RuntimeError, 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
				end
				movie_to_show = pick_movie_by_weight(suitable_movies)
				if @user_balance < movie_to_show.price.to_money
					raise StandardError, "Не хватает средств. Сейчас на балансе #{user_balance}, а данный фильм стоит #{movie_to_show.price}." 
				end
				@user_balance -= movie_to_show.price.to_money
				puts "Now showing #{movie_to_show.title}"	
				movie_to_show.description
			end

		end

		class Theatre < Cinema::Collections::MovieCollection

			include Cinema::CashboxImplementation::Cashbox

			SCHEDULE = {
				morning: {time: (6..11), filters: {period: :ancient}, price: 3},
				afternoon: {time: (12..17), filters: {genre:['Comedy', 'Adventure']}, price: 5},
				evening: {time: (18..23), filters: {genre:['Drama', 'Horror']}, price: 10}
			}

			def initialize(file)
				super
			end

			def show(time)
				check_time(time)
				period = SCHEDULE.detect{ |k, v| v[:time].include?(time.to_i)}.first
				movie_to_show = fetch_movie(period)
				puts "Now showing #{movie_to_show.title}"
				movie_to_show.description
			end

			def when?(movie_title)
				selected_movie = self.filter(title: movie_title)[0]
				movie_is_presented?(selected_movie)
				daytime,_ = SCHEDULE.detect{ |name, options| selected_movie.matches?(options[:filters])}
				"#{selected_movie.title} показывают с #{SCHEDULE[daytime][:time].first} до #{SCHEDULE[daytime][:time].last}"
			end

			def cash
				balance
			end

			def buy_ticket(movie_title)
				selected_movie = self.filter(title: movie_title)[0]
				movie_is_presented?(selected_movie)
				_,options = SCHEDULE.detect{ |name, options| selected_movie.matches?(options[:filters]) }
				movie_price = options[:price]
				replenish_balance(movie_price)
				"Вы купили билет на #{selected_movie.title}"
			end

			
			 

				def fetch_movie(period)
					pick_movie_by_weight(self.filter(SCHEDULE[period][:filters]))
				end

				def check_time(time)
					if !SCHEDULE.map{ |k, v| v[:time].to_a}.flatten.include?(time.to_i)
						raise RuntimeError, "Наш кинотеатр работает с #{SCHEDULE[:morning][:time].first} до #{SCHEDULE[:evening][:time].last}. Вы выбрали время #{time}."
					end
				end

				def movie_is_presented?(movie)
					if movie.nil?
						raise RuntimeError, 'Не найдено подходящих фильмов. Проверьте правильность ввода.'
					end
				end

		end

	end

end