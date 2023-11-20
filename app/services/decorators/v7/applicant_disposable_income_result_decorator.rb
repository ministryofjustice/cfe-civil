module Decorators
  module V7
    class ApplicantDisposableIncomeResultDecorator < V6::ApplicantDisposableIncomeResultDecorator
      def as_json
        super.except(:net_housing_costs, :gross_housing_costs)
      end
    end
  end
end
