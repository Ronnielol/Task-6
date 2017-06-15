# frozen_string_literal: true

module Cinema
  module Examples
    # Movie Theatre Example Class
    class Theatre < Cinema::MovieCollection
      include Cinema::Cashbox

      attr_accessor :hall, :periods

      DEFAULT_SCHEDULE = {
        morning: {
          time: ('6:00'..'11:00'),
          filters: { period: :ancient },
          price: 3
        },
        afternoon: {
          time: ('12:00'..'17:00'),
          filters: { genre: %w[Comedy Adventure] },
          price: 5
        },
        evening: {
          time: ('18:00'..'23:00'),
          filters: { genre: %w[Drama Horror] },
          price: 10
        }
      }.freeze

      def initialize(file, &block)
        super
        instance_eval(&block) if block_given?
        create_schedule
        check_schedule unless periods.nil?
      end

      def show(time)
        check_time(time)
        period = find_period(time)
        movie_to_show = fetch_movie(period[0])
        puts "Now showing #{movie_to_show.title}"
        movie_to_show.description
      end

      def find_period(time)
        @schedule.select do |_k, v|
          start_time = v[:time].first
          end_time = v[:time].last
          time_range(start_time, end_time).include?(Time.parse(time))
        end.first
      end

      def when?(movie_title)
        selected_movie = filter(title: movie_title)[0]
        movie_is_presented?(selected_movie)
        daytime, = @schedule.detect do |_name, options|
          selected_movie.matches?(options[:filters])
        end
        "#{selected_movie.title} показывают с"\
        " #{@schedule[daytime][:time].first} до"\
        " #{@schedule[daytime][:time].last}"
      end

      def cash
        balance
      end

      def buy_ticket(movie_title)
        selected_movie = filter(title: movie_title)[0]
        movie_is_presented?(selected_movie)
        _, options = @schedule.detect do |_name, options|
          selected_movie.matches?(options[:filters])
        end
        movie_price = options[:price]
        replenish_balance(movie_price)
        "Вы купили билет на #{selected_movie.title}"
      end

      private

      def hall(color, **attr_hash)
        @hall ||= []
        @hall << color
        @hall << attr_hash
      end

      def period(range, &period_settings)
        @periods ||= []
        p = Period.new(range, &period_settings)
        @periods << p
      end

      def create_schedule
        @schedule = if periods.nil?
                      DEFAULT_SCHEDULE
                    else
                      periods.map do |period|
                        [period.time.to_s.to_sym, period.to_h]
                      end.to_h
                    end
      end

      def check_schedule
        warnings = check_warnings(periods)
        show_warnings(warnings)
      end

      def check_warnings(periods)
        periods.combination(2).map do |p1, p2|
          p1.find_intersections(p2)
        end.compact
      end

      def show_warnings(warnings)
        return if warnings.empty?
        error_message = 'Пересечения периодов:'
        error_message_dup = error_message.dup
        warnings.each do |warning|
          error_message_dup << " c #{warning[:time].first} по"\
          " #{warning[:time].last} в зале #{warning[:hall]};"
        end
        raise StandardError, error_message_dup
      end

      def time_range(start_time, end_time)
        # Creates range of time for the period
        Range.new(Time.parse(start_time), Time.parse(end_time))
      end

      def fetch_movie(period)
        pick_movie_by_weight(filter(@schedule[period][:filters]))
      end

      def check_time(time)
        return if opening_hours.any? { |range| range.include?(Time.parse(time)) }
        raise 'Наш кинотеатр работает с'\
        " #{@schedule.values.first[:time].first} до"\
        " #{@schedule.values.last[:time].last}. Вы выбрали время #{time}."
      end

      def opening_hours
        @schedule.map do |_range, value|
          time_range(value[:time].first, value[:time].last)
        end
      end

      def movie_is_presented?(movie)
        return unless movie.nil?
        raise 'Не найдено подходящих фильмов.'\
          'Проверьте правильность ввода.'
      end
    end
  end
end
