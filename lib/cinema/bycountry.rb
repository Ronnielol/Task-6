# frozen_string_literal: true

module Cinema
  module Examples
    # This class defines filter methods by genres
    class ByCountry
      def initialize(collection)
        @collection = collection
      end

      def method_missing(meth)
        meth_name = meth.to_s
        @movies = @collection.select do |movie|
          country_match_regexp(movie, meth_name)
        end
        if check_movies(@movies, meth_name)
          @movies
        else
          super
        end
      end

      def respond_to_missing?(meth, include_all = true)
        !@movies.empty? || super
      end

      private

      def country_match_regexp(movie, parameter)
        movie.country =~ Regexp.new(parameter.to_s, Regexp::IGNORECASE)
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
