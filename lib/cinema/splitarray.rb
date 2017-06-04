module Cinema
  class SplitArray < Virtus::Attribute
    def coerce(value)
      value.include?(',') ? value.split(',') : value
    end
  end
end