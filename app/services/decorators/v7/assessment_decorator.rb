module Decorators
  module V7
    class AssessmentDecorator < V6::AssessmentDecorator
      def applicant_decorator(applicant_details)
        ApplicantDecorator.new applicant_details
      end
    end
  end
end
