# frozen_string_literal: true

module Cinema
  module Examples
    # Theatre period
    class Period
      POSSIBLE_NAMES = %w[link title year country date
                          genre length rating director actors].freeze

      attr_reader :time

      def initialize(range, &block)
        define_single_arg_methods
        instance_eval(&block) if block_given?
        @time = range
      end

      def define_single_arg_methods
        single_arg_meths = %w[description price]
        single_arg_meths.each do |meth|
          self.class.class_eval do
            attr_reader meth.to_s
            define_method meth do |arg = nil|
              return instance_variable_get(:"@#{meth}") if arg.nil?
              instance_variable_set(:"@#{meth}", arg)
            end
          end
        end
      end

      def hall(*colors)
        return @hall if colors.empty?
        @hall = colors
      end

      def filters(**filter_hash)
        return @filters if filter_hash.empty?
        @filters = filter_hash
      end

      def settings
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
