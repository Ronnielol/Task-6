module Cinema
  module Examples
    # Netflix example class
    class Netflix < Cinema::MovieCollection
      using MoneyHelper

      extend Cinema::Cashbox

      attr_accessor :user_balance, :custom_filters

      def initialize(file)
        super
        @custom_filters = {}
        @user_balance = 0.to_money
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

      # rubocop:disable LineLength
      def define_filter(filter_name, from: nil, arg: nil, &block)
        @custom_filters[filter_name.to_sym] = from ? derive_filter(filter_name, from, arg) : block
      end
      # rubocop:enable LineLength

      private

      def check_balance(movie)
        return unless @user_balance < movie.price.to_money
        raise StandardError, 'Не хватает средств.'\
        " Сейчас на балансе #{user_balance},"\
        " а данный фильм стоит #{movie.price}."
      end

      def find_suitable_movies(options, &block)
        # Finds movies depending on filter or block
        if block_given?
          suitable_movies = filter_with_block(block)
        else
          check_filter_exists(options)
          suitable_movies = custom_filter(options, &block) || filter(options)
        end
        got_movies?(suitable_movies)
        suitable_movies
      end

      def got_movies?(suitable_movies)
        return unless suitable_movies.empty?
        raise 'Не найдено подходящих по фильтрам фильмов.'\
          ' Проверьте правильность ввода.'
      end

      def arguments?(filter)
        return true unless filter.values[0].is_a?(TrueClass)
      end

      def custom_filter(given_filter)
        filter_name, filter_value = given_filter.first
        known_filter = @custom_filters[filter_name]
        return nil unless known_filter
        if arguments?(given_filter)
          filter_with_block(known_filter, filter_value)
        else
          filter_with_block(known_filter)
        end
      end

      def check_filter_exists(filter)
        # Raises error if filter does not exist in custom filters hash
        # or movie parameters
        filter_name = filter.keys[0].to_s
        return unless !custom_filter?(filter) && !HEADERS.include?(filter_name)
        raise StandardError, "Фильтр #{filter.keys[0]} не найден."\
          ' Проверьте правильность ввода.'
      end

      def filter_with_block(proc, *params)
        # Filter with user parameter
        if proc.parameters.length > 1
          @movies.select { |movie, _parameter| proc.call(movie, params[0]) }
        # Fitler whithout user parameter
        else
          @movies.select { |movie| proc.call(movie) }
        end
      end

      def derive_filter(_new_filter_name, defined_filter, parameter)
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
