module Cinema
  module Examples
    class ByGenre

      attr_reader :filter

      def initialize(collection)
        @filter = proc do |movie, given_genre|
          genre_match_regexp(movie, given_genre)
        end
        @genres = get_genres(collection).map(&:downcase)
        define_genre_methods(collection)
      end

      private

      def get_genres(collection)
        genres = collection
                           .map(&:genre)
                           .flatten
                           .uniq
        hyphen_to_underline(genres)
      end

      def hyphen_to_underline(string_array)
        string_array.map { |string| string.tr('-', '_') }
      end

      def genre_match_regexp(movie, given_genre)
        movie.genre.detect do |genre|
          genre =~ Regexp.new("#{given_genre}", Regexp::IGNORECASE)
        end
      end

      def define_genre_methods(collection)
        @genres.each do |genre|
          define_method_by_genre(genre, collection)
        end
      end

      def define_method_by_genre(genre, collection)
        self.class.instance_eval do
          define_method :"#{genre}" do
            find_movie_by_filter(genre, collection)
          end
        end
      end

      def find_movie_by_filter(genre, collection)
        collection.select do |movie|
          filter.call(movie, genre.tr('_', '-'))
        end
      end
    end
  end
end