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
          # rubocop:disable LineLength
          raise StandardError, 'Нельзя пополнить счет на 0 или отрициательное значение.'
          # rubocop:enable LineLength
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

      # rubocop:disable MethodLength
      def define_filter(filter_name, **redefine_filter, &block)
        if !redefine_filter.empty?
          # Define new filter based on already defined one
          define_filter_from_filter(
            filter_name,
            @custom_filters[redefine_filter[:from]],
            redefine_filter[:arg]
          )
        else
          @custom_filters = @custom_filters.merge(
            filter_name.to_sym => proc(&block)
          )
        end
      end
      # rubcopo:enable MethodLength

      private

      def check_balance(movie)
        # rubocop:disable LineLength
        raise StandardError, "Не хватает средств. Сейчас на балансе #{user_balance}, а данный фильм стоит #{movie.price}." if @user_balance < movie.price.to_money
        # rubocop:enable LineLength
      end

      def find_suitable_movies(options, &block)
        # Finds movies depending on filter or block
        if block_given?
          suitable_movies = filter_with_block(proc(&block))
        else
          suitable_movies = custom_filter(options, &block) || filter(options)
        end
        if suitable_movies.empty?
          # rubocop:disable LineLength
          raise 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
          # rubocop:enable LineLength
        end
        suitable_movies
      end

      # rubcopo:disable MethodLength
      def custom_filter(given_filter)
        check_filter_exists(given_filter)
        if custom_filter?(given_filter)
          case custom_filter_enabled?(given_filter)
          when true
            filter_with_block(@custom_filters[given_filter.keys[0]])
          when false
            []
          else
            # Filter with parameter if user set an additional one
            filter_with_block(
              @custom_filters[given_filter.keys[0]],
              given_filter.values[0]
            )
          end
        end
      end
      # rubcopo:enable MethodLength

      def check_filter_exists(filter)
        # Raises error if filter does not exist in custom filters hash
        # or movie parameters
        if !custom_filter?(filter) && !HEADERS.include?(filter.keys[0].to_s)
          # rubocop:disable LineLength
          raise StandardError, "Фильтр #{filter.keys[0]} не найден. Проверьте правильность ввода."
          # rubocop:enable LineLength
        end
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

      def define_filter_from_filter(new_filter_name, custom_filter, parameter)
        new_filter = proc do |movie, _arg|
          custom_filter.call(movie, parameter)
        end
        @custom_filters = @custom_filters.merge(
          new_filter_name.to_sym => new_filter
        )
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
