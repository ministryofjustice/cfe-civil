module Utilities
  class ChildcareExemptionDetector
    class << self
      def call(record_type, child_care_bank)
        return false unless record_type == :outgoings_childcare

        # If we have childcare records, but the 'bank' total value of
        # childcare is zero, that means childcare has evidently been disallowed
        # That means this child care record is exempt from checking.
        child_care_bank.zero?
      end
    end
  end
end
