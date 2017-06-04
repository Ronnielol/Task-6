module Cinema
  module Examples
    class ByCountry

      attr_reader :filter

      def initialize(collection)
        @filter = proc do |movie, parameter|
          country_match_regexp(movie, parameter)
        end
        @collection = collection
      end

      def method_missing(meth)
        meth_name = meth.to_s
        movies = @collection.select { |movie| filter.call(movie, meth_name) }
        movies if check_movies(movies, meth_name)
      end

      private

      def country_match_regexp(movie, parameter)
        movie.country =~ Regexp.new("#{parameter}", Regexp::IGNORECASE)
      end

      def check_movies(movies, meth_name)
        if movies.empty?
          raise "Фильмы из страны #{meth_name}"\
          ' не найдены. Проверьте правильность ввода.'
        else
          true
        end
      end
    end
  end
end