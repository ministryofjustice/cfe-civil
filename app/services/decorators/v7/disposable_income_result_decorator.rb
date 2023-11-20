module Decorators
  module V7
    class DisposableIncomeResultDecorator < V6::DisposableIncomeResultDecorator
      def as_json
        super.except(:gross_housing_costs, :net_housing_costs)
      end
    end
  end
end
