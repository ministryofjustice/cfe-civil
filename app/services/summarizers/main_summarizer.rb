module Summarizers
  class MainSummarizer
    class << self
      Result = Data.define(:assessment_result)
      def call(assessment:, receives_qualifying_benefit:, receives_asylum_support:,
               gross_income_eligibilities:, disposable_income_eligibilities:, capital_eligibilities:)
        assessment.proceeding_types.map(&:ccms_code).map do |ptc|
          Summarizers::AssessmentProceedingTypeSummarizer.call(
            proceeding_type_code: ptc,
            receives_qualifying_benefit:, receives_asylum_support:,
            gross_income_assessment_result: gross_income_eligibilities.detect { |e| e.proceeding_type_code == ptc }.assessment_result,
            disposable_income_result: disposable_income_eligibilities.detect { |e| e.proceeding_type_code == ptc }.assessment_result,
            capital_assessment_result: capital_eligibilities.detect { |e| e.proceeding_type_code == ptc }.assessment_result
          ).tap do |r|
            assessment.eligibilities.find_by!(proceeding_type_code: ptc).update!(assessment_result: r)
          end
        end
        Result.new(assessment_result: summarized_result(assessment.eligibilities.map(&:assessment_result)).to_s)
      end

    private

      def summarized_result(results)
        Utilities::ResultSummarizer.call(results)
      end
    end
  end
end
