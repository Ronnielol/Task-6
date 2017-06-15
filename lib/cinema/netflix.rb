# frozen_string_literal: true

module Cinema
  module Examples
    # Netflix example class
    class Netflix < Cinema::MovieCollection
      using MoneyHelper

      extend Cinema::Cashbox

      attr_accessor :user_balance, :custom_filters

      NO_MOVIES_FOUND_ERROR = 'Не найдено подходящих по фильтрам фильмов.'\
          ' Проверьте правильность ввода.'

      def initialize(file)
        super
        @custom_filters = {}
        @user_balance = 0.to_money
      end

      def by_genre
        Cinema::Examples::ByGenre.new(self)
      end

      def by_country
        Cinema::Examples::ByCountry.new(self)
      end

      def pay(amount)
        if amount <= 0
          raise StandardError, 'Нельзя пополнить счет на 0'\
          ' или отрициательное значение.'
        end
        @user_balance += amount.to_money
        self.class.replenish_balance(amount)
      end

      def how_much?(title)
        @movies.detect { |movie| movie.title == title }.price
      end

      def show(options = {}, &block)
        movie_to_show = pick_movie_by_weight(
          find_suitable_movies(options, &block)
        )
        check_balance(movie_to_show)
        @user_balance -= movie_to_show.price.to_money
        puts "Now showing #{movie_to_show.title}"
        movie_to_show.description
      end

      def define_filter(filter_name, from: nil, arg: nil, &block)
        @custom_filters[filter_name.to_sym] =
          if from
            derive_filter(from, arg)
          else
            block
          end
      end

      private

      def check_balance(movie)
        return unless @user_balance < movie.price.to_money
        raise StandardError, 'Не хватает средств.'\
        " Сейчас на балансе #{user_balance},"\
        " а данный фильм стоит #{movie.price}."
      end

      def find_suitable_movies(options, &block)
        # Finds movies depending on filter or block
        suitable_movies =
          if block_given?
            filter_by_block(block)
          else
            filter_by_name(options, &block)
          end
        raise NO_MOVIES_FOUND_ERROR if suitable_movies.empty?
        suitable_movies
      end

      def filter_by_name(given_filter, &block)
        check_filter_exists(given_filter)
        custom_filter(given_filter, &block) || filter(given_filter)
      end

      def arguments?(filter)
        !filter.values[0].is_a?(TrueClass)
      end

      def custom_filter(given_filter)
        filter_name, filter_value = given_filter.first
        known_filter = @custom_filters[filter_name]
        return nil unless known_filter
        if arguments?(given_filter)
          filter_by_block(known_filter, filter_value)
        else
          filter_by_block(known_filter)
        end
      end

      def check_filter_exists(filter)
        # Raises error if filter does not exist in custom filters hash
        # or movie parameters
        filter_name = filter.keys[0]
        return unless !custom_filter?(filter) && !HEADERS.include?(filter_name)
        raise StandardError, "Фильтр #{filter.keys[0]} не найден."\
          ' Проверьте правильность ввода.'
      end

      def filter_by_block(proc, *params)
        # Filter with user parameter
        if proc.parameters.length > 1
          @movies.select { |movie, _parameter| proc.call(movie, params[0]) }
        # Fitler whithout user parameter
        else
          @movies.select { |movie| proc.call(movie) }
        end
      end

      def derive_filter(defined_filter, parameter)
        custom_filter = @custom_filters[defined_filter]
        proc do |movie, _arg|
          custom_filter.call(movie, parameter)
        end
      end

      def custom_filter?(filter)
        @custom_filters.key?(filter.keys[0])
      end

      def custom_filter_enabled?(custom_filter)
        custom_filter.values[0]
      end
    end
  end
end
