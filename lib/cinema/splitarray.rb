# frozen_string_literal: true

module Cinema
  # Virtus attribute. Splits string with commas into array.
  class SplitArray < Virtus::Attribute
    def coerce(value)
      value.split(',')
    end
  end
end
