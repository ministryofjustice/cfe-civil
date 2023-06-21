module Decorators
  module V6
    class PropertyDecorator
      def initialize(property, result)
        @record = property
        @result = result
      end

      def as_json
        payload unless @record.nil?
      end

    private

      def payload
        {
          value: @record.value,
          outstanding_mortgage: @record.outstanding_mortgage,
          percentage_owned: @record.percentage_owned,
          main_home: @record.main_home,
          shared_with_housing_assoc: @record.shared_with_housing_assoc,
          transaction_allowance: @result.transaction_allowance,
          allowable_outstanding_mortgage: @record.outstanding_mortgage,
          net_value: @result.net_value,
          net_equity: @result.net_equity,
          smod_allowance: @result.smod_allowance,
          main_home_equity_disregard: @result.main_home_equity_disregard,
          assessed_equity: @result.assessed_equity,
        }
      end
    end
  end
end
