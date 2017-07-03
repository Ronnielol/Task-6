# frozen_string_literal: true
# Cinema gem module.
module Cinema
  # Movie class represents single movie in collection. Carries information about that movie.
  # @attr link [String] Imdb link.
  # @attr title [String] Movie title.
  # @attr year [Fixnum] Movie release year.
  # @attr country [String] Movie country.
  # @attr date [Date] Movie release date.
  # @attr genre [SplitArray] Movie genres.
  # @attr length [String] Movie length.
  # @attr rating [Float] Movie imdb rating.
  # @attr director [String] Movie director.
  # @attr actors [SplitArray] Movie main actors.
  # @attr collection [MovieCollection] Collection of the movie.
  # @attr price [Money] Movie price.
  class Movie
    include Virtus.model

    attribute :link, String
    attribute :title, String
    attribute :year, Integer
    attribute :country, String
    attribute :date, Date
    attribute :genre, SplitArray
    attribute :length, String
    attribute :rating, Float
    attribute :director, String
    attribute :actors, SplitArray
    attribute :collection

    attr_reader :price
    # Gets movie period.
    # @return [Sybmol] movie perod.
    # @example Get movie period
    #   "movie.period" #=> ":ancient"
    def period
      self.class
          .name.sub(/^Cinema::(.+)Movie$/, '\1')
          .downcase
          .to_sym
    end

    # Creates new instance of a movie.
    # @param attribute_hash [Hash]
    def self.create(attribute_hash)
      period_settings = find_period_setting(attribute_hash[:year])
      movie_class = period_settings[:movie_class]
      movie_class.new(attribute_hash)
    end
    # Depending on movie year this method looks for appropriate period in PERIODS constant.
    def self.find_period_setting(movie_year)
      _, period_settings = PERIODS.detect do |_period, value|
        value[:years].cover?(movie_year)
      end
      if period_settings.nil?
        raise 'У фильма неподходящий год.'\
      ' В базе могут быть только фильмы, снятые с 1900 года по настоящий.'
      end
      period_settings
    end
    # Takes genre as an argument and checks if movie suits this genre.
    # Raises error if given genre isn't represented in collection.
    # @param genre [String] movie genre.
    def genre?(genre)
      unless collection.genre_exists?(genre)
        raise ArgumentError, 'Аргумент задан с ошибкой,'\
        ' либо такого жанра не существует.'
      end
      @genre.include? genre
    end
    # Checks if movie matches given filters.
    # @param filters [Array] list of filters.
    # @return [Boolean]
    def matches?(filters)
      # Creating array for filters check results
      filter_check_array = filters.map do |filter_name, filter_value|
        match_filter?(filter_name, filter_value)
      end
      # Returns true only if all filters passed (were 'true' for the movie)
      filter_check_array.none? { |status| status == false }
    end
    # Returns all movie attributes as hash (w/o collection)
    # @return [Hash] atrributes hash
    def to_h
      {
        imdb_id: link.split('/')[4],
        title: title,
        link: link,
        year: year,
        country: country,
        date: date,
        genre: genre,
        length: length,
        rating: rating,
        director: director,
        actors: actors
      }
    end

    private
    # Checks if movie matches single filter.
    # @param filter_name [String] filter key
    # @param filter_value [String] filter value
    # @return [Boolean]
    def match_filter?(filter_name, filter_value)
      if filter_name =~ /^exclude_(.+)/
        value = send(Regexp.last_match(1))
        !value_match?(value, filter_value)
      else
        value = send(filter_name)
        value_match?(value, filter_value)
      end
    end
    # Checks if filter value matches movie attribute.
    # @see #match_filter?
    # @return [Boolean]
    def value_match?(value, filter_value)
      if filter_value.is_a?(Array)
        value_match_array?(value, filter_value)
      else
        value_match_string?(value, filter_value)
      end
    end
    # This matcher comes into play if filter value is an Array.
    # @see #value_match?
    # @return [Boolean]
    def value_match_array?(value, filter_value)
      if value.is_a?(Array)
        !(filter_value & value).empty?
      else
        filter_value.any? { |fv| fv === value }
      end
    end
    # This matcher comes into play if filter value is a String.
    # @see #value_match?
    # @return [Boolean]
    def value_match_string?(value, filter_value)
      if value.is_a?(Array)
        value.include?(filter_value)
      else
        filter_value === value
      end
    end
  end

  # Class AncientMovie is assigned to movie if movie year < 1945
  # @see Movie#create
  class AncientMovie < Movie
    using MoneyHelper
    # Initializer. Adds price to movie.
    def initialize(attribute_hash)
      super
      @price = 1.to_money
    end
    # Returns movie description.
    # @return [String] movie description.
    def description
      "#{title} - старый фильм #{year}"
    end
  end

  # Class ClassicMovie is assigned to movie if movie year 1945..1967
  # @see Movie#create
  class ClassicMovie < Movie
    using MoneyHelper
    # Initializer. Adds price to movie.
    def initialize(attribute_hash)
      super
      @price = 1.5.to_money
    end
    # Returns movie description.
    # @return [String] movie description.
    def description
      "#{title} - классический фильм #{director}"\
      " (ещё #{collection.stats(:director)[director] - 1}"\
      ' его фильмов в списке)'
    end
  end

  # Class ModerntMovie is assigned to movie if movie year 1968..1999
  # @see Movie#create
  class ModernMovie < Movie
    using MoneyHelper
    # Initializer. Adds price to movie.
    def initialize(attribute_hash)
      super
      @price = 3.to_money
    end
    # Returns movie description.
    # @return [String] movie description.
    def description
      "#{title} - современное кино: играют #{actors.join(',')}"
    end
  end

  # Class NewMovie is assigned to movie if movie year 2000..today
  # @see Movie#create
  class NewMovie < Movie
    using MoneyHelper
    # Initializer. Adds price to movie.
    def initialize(attribute_hash)
      super
      @price = 5.to_money
    end
    # Returns movie description.
    # @return [String] movie description.
    def description
      "#{title} - новинка, вышло #{Date.today.cwyear - year.to_i} лет назад"
    end
  end

  class Movie
    # This constant contains periods settings.
    # If you want to change movie class names (movie_class), you must also change Movie subclasses.
    PERIODS =
      {
        ancient: { years: 1900..1944, movie_class: AncientMovie },
        classic: { years: 1945..1967, movie_class: ClassicMovie },
        modern: { years: 1968..1999, movie_class: ModernMovie },
        new: { years: 2000..Date.today.cwyear, movie_class: NewMovie }
      }.freeze
  end
end
