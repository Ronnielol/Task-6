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
      if exclude_filters?(filters)
        # Find movies with common filters
        filtered_movies = @movies.select do |movie| movie.matches?(get_match_filters(filters))
        end
        # Reject movies with exclude filters
        filtered_movies.reject do |movie| movie.matches?(get_exclude_filters(filters))
        end
      else
        @movies.select { |movie| movie.matches?(filters) }
      end
    end

    private

    def pick_movie_by_weight(movies)
      movies.sort_by { |movie| rand * movie.rating }[0]
    end

    def exclude_filters?(filters)
      filters.any? do |key, value|
        key.to_s.match(/exclude/)
      end
    end

    def get_match_filters(filters)
      filters.reject { |key, value| key.to_s.match(/exclude/) }
    end

    def get_exclude_filters(filters)
      # This method creates common filter from exclude filter
      exclude_filters = filters.select { |k, v| k.to_s.match(/exclude/) }
      # Get the right names for keys
      mappings = exclude_filters.map do
        |k, v| { k => k.to_s.gsub('exclude_', '').to_sym }
      end[0]
      # Assign right names to keys
      exclude_filters.map {|k, v| [mappings[k], v] }.to_h
    end
  end
end
