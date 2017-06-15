# frozen_string_literal: true

module Cinema
  module Examples
    # Theatre period
    class Period
      POSSIBLE_NAMES = %w[link title year country date
                          genre length rating director actors].freeze

      attr_reader :time

      def initialize(range, &block)
        instance_eval(&block) if block_given?
        @time = range
      end

      def price(value = nil)
        return @price unless value
        @price = value
      end

      def description(value = nil)
        return @description unless value
        @description = value
      end

      def hall(*colors)
        return @hall if colors.empty?
        @hall = colors
      end

      def filters(**filter_hash)
        return @filters if filter_hash.empty?
        @filters = filter_hash
      end

      def find_intersections(period)
        # Find time intersections
        time = (self.time.to_a & period.time.to_a)
        # Find hall intersections
        hall = (self.hall & period.hall)
        return if (time.size < 2) || hall.empty?
        { time: time, hall: hall }
      end

      def to_h
        {
          time: time,
          filters: filters,
          price: price,
          hall: hall
        }
      end

      def method_missing(meth, arg)
        meth_name = meth.to_s
        if POSSIBLE_NAMES.include?(meth_name)
          @filters = { meth_name.to_sym => arg }
        else
          super
        end
      end

      def respond_to_missing?(meth, include_all = true)
        POSSIBLE_NAMES.include?(meth.to_s) || super
      end
    end
  end
end
