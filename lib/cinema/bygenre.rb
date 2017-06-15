# frozen_string_literal: true

module Cinema
  module Examples
    # This class defines filter methods by genres
    class ByGenre
      def initialize(collection)
        collection.genres.each do |genre|
          define_singleton_method(genre_to_method_name(genre)) do
            collection.filter(genre: genre)
          end
        end
      end

      private

      def genre_to_method_name(genre)
        genre.tr('-', '_').downcase
      end
    end
  end
end
