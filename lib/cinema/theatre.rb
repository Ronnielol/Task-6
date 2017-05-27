module Cinema
  module Examples
    # Movie Theatre Example Class
    class Theatre < Cinema::MovieCollection
      include Cinema::Cashbox
      include Cinema::Examples::DSLHelper

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
        if block_given?
          self.class.class_eval(&block)
          copyvars
        end
        create_schedule
        check_schedule unless periods.nil?
      end

      def check_schedule
        warnings = find_warnings(periods)
        show_warnings(warnings)
      end

      def find_warnings(periods)
        # Iterate between periods-array and clone-periods-array to find crossings
        periods.each_with_index.map do |period, first_index|
          periods.each_with_index.map do |second_period, second_index|
            # Iterate only if period index is different from clone period index
            unless (first_index == second_index)
               # Find joint time between periods
              joint_time = (period.time.to_a & second_period.time.to_a)
               # Find joint halls between periods
              joint_hall = (period.hall & second_period.hall)
              generate_warning(joint_time, joint_hall)
            end
          end
        end
      end

      def generate_warning(time, hall)
        # Time and halls array must not be empty
        if !time.empty? && !hall.empty?
          # Dont generate false warnings (example: '9:00..'16:00' and '16:00'..'20:00')
          {time: time, hall: hall} unless (time.first == time.last)
        end
      end

      def show_warnings(warnings)
        # Delete duplicates and nils
        nrmlz_warnings = warnings.flatten.uniq.compact
        return if nrmlz_warnings.empty?
        error_message = "Пересечения периодов:"
        nrmlz_warnings.each do |warning|
          error_message << " c #{warning[:time].first} по #{warning[:time].last} в зале #{warning[:hall].to_s};"
        end
        raise StandardError, error_message
      end

      def show(time)
        check_time(time)
        period = @schedule.detect do |_k, v|
          start_time = v[:time].first
          end_time = v[:time].last
         time_range(start_time, end_time).include?(Time.parse(time))
        end.first
        movie_to_show = fetch_movie(period)
        puts "Now showing #{movie_to_show.title}"
        movie_to_show.description
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

      def self.hall(color, **attr_hash)
        @hall ||= []
        @hall << color
        @hall << attr_hash
      end

      def self.period(range, &period_settings)
        @periods ||= []
        p = Period.new(range, &period_settings)
        @periods << p
        p.copyvars
      end

      private

      def create_schedule
        @schedule = {}
        unless periods.nil?
          periods.each do |period|
            @schedule[period.time.to_s.to_sym] = period.schedule
          end
        else
          @schedule = DEFAULT_SCHEDULE
        end
      end

      def time_range(start_time, end_time)
        # Creates range of time for the period
        Range.new(Time.parse(start_time),Time.parse(end_time))
      end

      def fetch_movie(period)
        pick_movie_by_weight(filter(@schedule[period][:filters]))
      end

      def check_time(time)
        unless opening_hours.any? {|range| range.include?(Time.parse(time))}
          raise 'Наш кинотеатр работает с'\
          " #{@schedule.values.first[:time].first} до"\
          " #{@schedule.values.last[:time].last}. Вы выбрали время #{time}."
        end
      end

      def opening_hours
        @schedule.map do |range, value|
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
