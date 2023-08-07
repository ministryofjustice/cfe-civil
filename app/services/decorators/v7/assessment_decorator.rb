module Decorators
  module V7
    class AssessmentDecorator < V6::AssessmentDecorator
      def applicant_decorator_class
        ApplicantDecorator
      end
    end
  end
end
