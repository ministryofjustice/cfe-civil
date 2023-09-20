module Utilities
  class NumberUtilities
    class << self
      def positive_or_zero(value)
        [value, 0.0].max
      end
    end
  end
end
