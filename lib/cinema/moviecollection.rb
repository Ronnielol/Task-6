# frozen_string_literal: true
# Cinema gem module
module Cinema
  # The MovieCollection class represents basic movie collection.
  # @param format [String] the format type, `file.csv`
  # @return [MovieCollection] object that contains all movies from the file.
  class MovieCollection
    include Enumerable
    # CSV File headers.
    # More info on https://ruby-doc.org/stdlib-2.4.0/libdoc/csv/rdoc/CSV.html
    HEADERS = %i[link title year country date
                 genre length rating director actors].freeze
    # This method allows to use Enumerable methods.
    def each(&block)
      @movies.each(&block)
    end

    # Collect genres from all movies in collection.
    # @return [Array] All genres list.
    def genres
      flat_map(&:genre).uniq
    end
    # Creates new instance and parses given csv file.
    # @param file [File] CSV file
    def initialize(file)
      @movies = CSV.foreach(
        file, col_sep: '|', headers: HEADERS,
              force_quotes: 'false', converters: [:numeric]
      ).map { |row| Cinema::Movie.create(get_movie_attrs(row)) }
    end
    # This method counts movies attribute values in collection by given attribute name.
    # @param arg [Symbol]
    # @return [Hash]
    # @example Get director stats.
    #   "movie.stats(:director)" #=> "{"Frank Darabont"=>2}"
    def stats(arg)
      @movies
        .map(&arg)
        .compact
        .each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
    end
    # Lets you to filter collection by movie arguments.
    # Multiple filters are allowed.
    # @param filters [Array<Hash>] List of filters.
    def filter(filters)
      @movies.select { |movie| movie.matches?(filters) }
    end

    private
    # Pick random movie to show.
    # Movies with higher rating has higher priority.
    # @private
    def pick_movie_by_weight(movies)
      movies.sort_by { |movie| rand * movie.rating }[0]
    end
    # This method makes hash from csv row.
    # @param row [String] Movie info from csv
    # @return [Hash]
    # @private
    def get_movie_attrs(row)
      attrs_from_csv = row.to_h
      # Add collection to movie attrs
      attrs_from_csv.merge(collection: self)
    end
  end
end
