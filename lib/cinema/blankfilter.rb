# frozen_string_literal: true

module Cinema
  module Examples
    # This class handles pretty filters methods (by_country, by_genre and so on)
    class BlankFilter
      attr_reader :filter

      GENRES = ['Crime', 'Drama', 'Action', 'Biography',
                'History', 'Western', 'Adventure', 'Fantasy', 'Romance',
                'Mystery', 'Sci-Fi', 'Thriller', 'Family', 'Comedy', 'War',
                'Animation', 'Horror', 'Music', 'Film-Noir', 'Musical', 'Sport'].freeze

      def initialize(collection, header)
        @filter = proc do |movie, parameter|
          movie.send(header).include?(parameter)
        end
        @collection = collection
        @header = header
        define_genres_methods(@collection)
      end

      def define_genres_methods(collection)
        genres = GENRES.map { |genre| genre.tr('-', '_').downcase }
        genres.each do |genre|
          self.class.class_eval do
            define_method :"#{genre}" do
              collection.select { |movie| filter.call(movie, genre) }
            end
          end
        end
      end

      def method_missing(meth)
        if @header == 'country'
          meth_name = normalize_method_name(meth)
          movies = @collection.select { |movie| filter.call(movie, meth_name) }
          movies if got_movies?(movies, meth_name)
        else
          super
        end
      end

      def got_movies?(movies, meth_name)
        if movies.empty?
          raise "Фильмы из страны #{meth_name}"\
          ' не найдены. Проверьте правильность ввода.'
        else
          true
        end
      end

      def normalize_method_name(meth)
        if meth.to_s == 'usa'
          meth.to_s.upcase
        else
          meth.to_s.capitalize
        end
      end

      def respond_to_missing?(meth, include_all = true)
        @header.include?('country') || super
      end
    end
  end
end
