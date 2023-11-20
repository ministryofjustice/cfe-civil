module Decorators
  module V7
    class AssessmentDecorator < V6::AssessmentDecorator
      def applicant_decorator_class
        ApplicantDecorator
      end

      def result_summary_decorator_class
        ResultSummaryDecorator
      end
    end
  end
end
