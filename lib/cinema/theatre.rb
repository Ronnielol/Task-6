module Cinema
  module Examples
    # Movie Theatre Example Class
    class Theatre < Cinema::MovieCollection
      include Cinema::Cashbox

      SCHEDULE = {
        morning: {
          time: (6..11),
          filters: { period: :ancient },
          price: 3
        },
        afternoon: {
          time: (12..17),
          filters: { genre: %w[Comedy Adventure] },
          price: 5
        },
        evening: {
          time: (18..23),
          filters: { genre: %w[Drama Horror] },
          price: 10
        }
      }.freeze

      def initialize(file)
        super
      end

      def show(time)
        check_time(time)
        period = SCHEDULE.detect { |_k, v| v[:time].include?(time.to_i) }.first
        movie_to_show = fetch_movie(period)
        puts "Now showing #{movie_to_show.title}"
        movie_to_show.description
      end

      def when?(movie_title)
        selected_movie = filter(title: movie_title)[0]
        movie_is_presented?(selected_movie)
        daytime, = SCHEDULE.detect do |_name, options|
          selected_movie.matches?(options[:filters])
        end
        # rubocop:disable LineLength
        "#{selected_movie.title} показывают с #{SCHEDULE[daytime][:time].first} до #{SCHEDULE[daytime][:time].last}"
        # rubocop:enable LineLength
      end

      def cash
        balance
      end

      def buy_ticket(movie_title)
        selected_movie = filter(title: movie_title)[0]
        movie_is_presented?(selected_movie)
        _, options = SCHEDULE.detect do |_name, options|
          selected_movie.matches?(options[:filters])
        end
        movie_price = options[:price]
        replenish_balance(movie_price)
        "Вы купили билет на #{selected_movie.title}"
      end

      private

      def fetch_movie(period)
        pick_movie_by_weight(filter(SCHEDULE[period][:filters]))
      end

      def check_time(time)
        unless SCHEDULE.map { |_k, v| v[:time].to_a }
                       .flatten
                       .include?(time.to_i)
          # rubocop:disable LineLength
          raise "Наш кинотеатр работает с #{SCHEDULE[:morning][:time].first} до #{SCHEDULE[:evening][:time].last}. Вы выбрали время #{time}."
          # rubocop:enable LineLength
        end
      end

      def movie_is_presented?(movie)
        # rubocop:disable LineLength
        raise 'Не найдено подходящих фильмов. Проверьте правильность ввода.' if movie.nil?
        # rubocop:enable LineLength
      end
    end
  end
end
