# frozen_string_literal: true

module Cinema
  # Gathers movies info from file and creates collection
  class MovieCollection
    include Enumerable

    HEADERS = %w[link title year country date
                 genre length rating director actors].freeze

    def each(&block)
      @movies.each(&block)
    end

    def initialize(file)
      @movies = CSV.foreach(
        file, col_sep: '|', headers: HEADERS,
              force_quotes: 'false', converters: [:numeric]
      ).map do |row|
        Cinema::Movie.create(
          link: row['link'],
          title: row['title'],
          year: row['year'],
          country: row['country'],
          date: parse_date(row['date']),
          genre: row['genre'],
          length: row['length'],
          rating: row['rating'],
          director: row['director'],
          actors: row['actors'],
          collection: self
        )
      end
    end

    def parse_date(date)
      Date.parse(date) if date.to_s.length > 7
    end

    def stats(arg)
      @movies
        .map(&arg)
        .compact
        .each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
    end

    def filter(filters)
      @movies.select { |movie| movie.matches?(filters) }
      #exclude?(filters)
    end

    def exclude?(filters)
      filters.keys.any? do |key|
        HEADERS.any? { |header| key == "exclude_#{header}" }
      end
    end

    private

    def pick_movie_by_weight(movies)
      movies.sort_by { |movie| rand * movie.rating }[0]
    end
  end
end
