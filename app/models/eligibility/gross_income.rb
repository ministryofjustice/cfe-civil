module Eligibility
  GrossIncome = Data.define :proceeding_type, :assessment_result, :upper_threshold do
    def lower_threshold
      nil
    end
  end
end
