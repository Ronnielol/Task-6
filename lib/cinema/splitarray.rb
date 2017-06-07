# frozen_string_literal: true

module Cinema
  # Virtus attribute. Splits string with commas into array.
  class SplitArray < Virtus::Attribute
    def coerce(value)
      value.include?(',') ? value.split(',') : [value]
    end
  end
end
