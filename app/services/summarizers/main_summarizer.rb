module Summarizers
  class MainSummarizer
    class << self
      Result = Data.define(:assessment_result)
      def call(assessment:, receives_qualifying_benefit:, receives_asylum_support:)
        assessment.proceeding_types.map(&:ccms_code).each do |ptc|
          Summarizers::AssessmentProceedingTypeSummarizer.call(assessment:, proceeding_type_code: ptc,
                                                               receives_qualifying_benefit:, receives_asylum_support:)
        end
        Result.new(assessment_result: summarized_result(assessment.eligibilities))
      end

    private

      def summarized_result(eligibilities)
        Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
      end
    end
  end
end
