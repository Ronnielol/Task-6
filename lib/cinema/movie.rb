module Cinema
  # Movie class contains info about certain movie
  class Movie
    attr_reader :link, :title, :year, :country, :date,
                :genre, :length, :rating, :director,
                :actors, :collection, :price, :period

    def initialize(link, title, year, country, # rubocop:disable ParameterLists
                   date, genre, length, rating,
                   director, actors, collection)
      @date, @link, @title, @year, @country, @genre, @length,
      @rating, @director, @actors, @collection, @period =
        parse_date(date), link, title, year, country, parse_array(genre),
        length, rating, director, parse_array(actors), collection, period
    end

    def parse_date(date)
      Date.parse(date) if date.to_s.length > 7
    end

    def parse_array(array)
      array.split(',')
    end

    def period
      self.class
          .name.sub(/^Cinema::(.+)Movie$/, '\1')
          .downcase
          .to_sym
    end

    def self.create(row, collection)
      period_settings = find_period_setting(row)
      check_year(period_settings)
      movie_class = period_settings[:movie_class]
      movie_class.new(
        row['link'], row['title'], row['year'],
        row['country'], row['date'], row['genre'],
        row['length'], row['rating'], row['director'],
        row['actors'], collection
      )
    end

    # rubocop:disable CaseEquality
    def self.find_period_setting(movie_parameters)
      _, period_settings = PERIODS.detect do |_period, value|
        value[:years] === movie_parameters['year']
      end
      period_settings
    end
    # rubocop:enable CaseEquality

    def self.check_year(movie_parameters)
      return unless movie_parameters.nil?
      raise 'У фильма неподходящий год.'\
      ' В базе могут быть только фильмы, снятые с 1900 года по настоящий.'
    end

    def genre?(genre)
      unless @collection.genre_exists?(genre)
        raise ArgumentError, 'Аргумент задан с ошибкой,'\
        ' либо такого жанра не существует.'
      end
      @genre.include? genre
    end

    def matches?(filters)
      filters.any? do |filter_name, filter_value|
        match_filter?(filter_name, filter_value)
      end
    end

    def match_filter?(filter_name, filter_value)
      value = send(filter_name)
      if value.is_a?(Array)
        value.any? { |v| value_match?(v, filter_value) }
      else
        value_match?(value, filter_value)
      end
    end

    # rubocop:disable CaseEquality
    def value_match?(value, filter_value)
      if filter_value.is_a?(Array)
        filter_value.any? { |fv| fv === value }
      else
        filter_value === value
      end
    end
    # rubocop:enable CaseEquality
  end

  # Movie gets this class if movie year < 1945
  class AncientMovie < Movie
    using MoneyHelper
    # rubocop:disable ParameterLists
    def initialize(link, title, year, country, date,
                   genre, length, rating, director, actors, collection)
      super
      @price = 1.to_money
    end
    # rubocop:enable ParameterLists

    def description
      "#{title} - старый фильм #{year}"
    end
  end

  # Movie gets this class if movie year 1945..1967
  class ClassicMovie < Movie
    using MoneyHelper
    # rubocop:disable ParameterLists
    def initialize(link, title, year, country, date,
                   genre, length, rating, director, actors, collection)
      super
      @price = 1.5.to_money
    end
    # rubocop:enable ParameterLists

    def description
      "#{title} - классический фильм #{director}"\
      " (ещё #{collection.stats(:director)[director] - 1}"\
      ' его фильмов в списке)'
    end
  end

  # Movie gets this class if movie year 1968..1999
  class ModernMovie < Movie
    using MoneyHelper
    # rubocop:disable ParameterLists
    def initialize(link, title, year, country, date,
                   genre, length, rating, director, actors, collection)
      super
      @price = 3.to_money
    end

    # rubocop:enable ParameterLists
    def description
      "#{title} - современное кино: играют #{actors.join(', ')}"
    end
  end

  # Movie gets this class if movie year 2000..today
  class NewMovie < Movie
    using MoneyHelper
    # rubocop:disable ParameterLists
    def initialize(link, title, year, country, date,
                   genre, length, rating, director, actors, collection)
      super
      @price = 5.to_money
    end

    # rubocop:enable ParameterLists
    def description
      "#{title} - новинка, вышло #{Date.today.cwyear - year.to_i} лет назад"
    end
  end

  class Movie
    PERIODS =
      {
        ancient: { years: 1900..1944, movie_class: AncientMovie },
        classic: { years: 1945..1967, movie_class: ClassicMovie },
        modern: { years: 1968..1999, movie_class: ModernMovie },
        new: { years: 2000..Date.today.cwyear, movie_class: NewMovie }
      }.freeze
  end
end
