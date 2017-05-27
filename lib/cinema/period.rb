module Cinema
  module Examples
    class Period
      include Cinema::Examples::DSLHelper

      attr_accessor :description, :filters, :price, :hall, :time

      def initialize(range, &block)
        self.class.class_eval(&block)
        @time = range
        copyvars
      end

      def self.description(string)
        @description = string
      end

      def self.price(integer)
        @price = integer
      end

      def self.hall(*colors)
        @hall = colors
      end

      def self.filters(**filter_hash)
        @filters = filter_hash
      end

      def schedule
        {
          time: time,
          filters: filters,
          price: price,
          hall: hall
        }
      end

      def self.method_missing(meth, arg)
        possible_names = %w[link title year country date
                 genre length rating director actors]
        meth_name = meth.to_s
        if possible_names.include?(meth_name)
          @filters = { meth_name.to_sym => arg }
        end
      end
    end
  end
end