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
        movies = @collection.select do |movie|
          country_match_regexp(movie, meth_name)
        end
        super if movies.empty?
      end

      def respond_to_missing?(meth)
        @collection.any? { |movie| country_match_regexp(movie, meth.to_s) }
      end

      private

      def country_match_regexp(movie, parameter)
        movie.country =~ Regexp.new(parameter.to_s, Regexp::IGNORECASE)
      end
    end
  end
end
