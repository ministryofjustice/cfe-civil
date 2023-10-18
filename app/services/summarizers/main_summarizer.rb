module Summarizers
  class MainSummarizer
    class << self
      def assessment_results(proceeding_types:, receives_qualifying_benefit:, receives_asylum_support:,
                             gross_income_assessment_results:, disposable_income_assessment_results:, capital_assessment_results:)
        values = proceeding_types.map do |proceeding_type|
          assessment_result = Summarizers::AssessmentProceedingTypeSummarizer.call(
            proceeding_type_code: proceeding_type.ccms_code,
            receives_qualifying_benefit:,
            receives_asylum_support:,
            gross_income_assessment_result: gross_income_assessment_results.fetch(proceeding_type),
            disposable_income_result: disposable_income_assessment_results.fetch(proceeding_type),
            capital_assessment_result: capital_assessment_results.fetch(proceeding_type),
          )
          [proceeding_type, assessment_result]
        end
        values.to_h
      end
    end
  end
end
