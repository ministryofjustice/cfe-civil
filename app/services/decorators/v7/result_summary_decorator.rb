module Decorators
  module V7
    class ResultSummaryDecorator < V6::ResultSummaryDecorator
    private

      def applicant_disposable_income_result_decorator_class
        ApplicantDisposableIncomeResultDecorator
      end

      def disposable_income_result_decorator_class
        DisposableIncomeResultDecorator
      end
    end
  end
end
