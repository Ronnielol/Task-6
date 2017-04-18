module Cinema
  module Examples
    class Netflix < Cinema::MovieCollection
      using MoneyHelper

      extend Cinema::Cashbox

      attr_accessor :user_balance

      def initialize(file)
        super
        @custom_filters = []
        @user_balance = 0.to_money
      end

      def pay(amount)
        if amount <= 0
          raise StandardError, 'Нельзя пополнить счет на 0 или отрициательное значение.'
        end
        @user_balance += amount.to_money
        self.class.replenish_balance(amount)
      end

      def how_much?(title)
        @movies.detect { |movie| movie.title == title }.price
      end

      def show(options = {}, &block)
        suitable_movies = custom_filter(options) || filter(options)
        suitable_movies = filter_with_block(proc(&block)) if block_given?
        if suitable_movies.empty?
          raise 'Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.'
        end
        movie_to_show = pick_movie_by_weight(suitable_movies)
        if @user_balance < movie_to_show.price.to_money
          raise StandardError, "Не хватает средств. Сейчас на балансе #{user_balance}, а данный фильм стоит #{movie_to_show.price}."
        end
        @user_balance -= movie_to_show.price.to_money
        puts "Now showing #{movie_to_show.title}"
        movie_to_show.description
      end

      def define_filter(filter_name, &block)
        @custom_filters << { filter_name.to_sym => proc(&block) }
      end

      private

      def custom_filter(given_filter)
        # Check if custom filter given and enabled
        if custom_filter?(given_filter) && custom_filter_enabled?(given_filter)
          filter_with_block(find_custom_filter(given_filter))
        # Check if custom filter given and disabled
        elsif custom_filter?(given_filter) && !custom_filter_enabled?(given_filter)
          []
        end
      end

      def filter_with_block(proc)
        @movies.select { |movie| proc.call(movie) }
      end

      def find_custom_filter(filter)
        @custom_filters.detect { |filter_hash| filter_hash.keys.include?(filter.keys[0]) }.values[0]
      end

      def custom_filter?(filter)
        !HEADERS.include?(filter.keys[0].to_s)
      end

      def custom_filter_enabled?(custom_filter)
        custom_filter.values[0]
      end
    end
  end
end
