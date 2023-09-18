module Summarizers
  class MainSummarizer
    class << self
      Results = Data.define(:eligibilities, :assessment_result)

      def call(proceeding_types:, receives_qualifying_benefit:, receives_asylum_support:,
               gross_income_eligibilities:, disposable_income_eligibilities:, capital_eligibilities:)
        eligibilities = proceeding_types.map do |ptc|
          r = Summarizers::AssessmentProceedingTypeSummarizer.call(
            proceeding_type_code: ptc.ccms_code,
            receives_qualifying_benefit:,
            receives_asylum_support:,
            gross_income_assessment_result: gross_income_eligibilities.detect { |e| e.proceeding_type == ptc }.assessment_result,
            disposable_income_result: disposable_income_eligibilities.detect { |e| e.proceeding_type == ptc }.assessment_result,
            capital_assessment_result: capital_eligibilities.detect { |e| e.proceeding_type == ptc }.assessment_result,
          )
          Eligibility::Assessment.new(assessment_result: r, proceeding_type: ptc).freeze
        end
        Results.new(eligibilities:,
                    assessment_result: Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result)).to_s)
      end
    end
  end
end
