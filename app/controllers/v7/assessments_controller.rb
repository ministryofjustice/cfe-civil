module V7
  class AssessmentsController < V6::AssessmentsController
  private

    def assessment_decorator_class
      Decorators::V7::AssessmentDecorator
    end

    def version
      "7"
    end
  end
end
