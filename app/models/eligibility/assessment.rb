module Eligibility
  Assessment = Data.define :proceeding_type, :assessment_result do
    def upper_threshold
      nil
    end

    def lower_threshold
      nil
    end
  end
end
