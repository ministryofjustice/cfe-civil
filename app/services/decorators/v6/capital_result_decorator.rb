module Decorators
  module V6
    class CapitalResultDecorator
      def initialize(summary, person_capital_subtotals)
        @summary = summary
        @person_capital_subtotals = person_capital_subtotals
      end

      def as_json
        {
          pensioner_disregard_applied: @person_capital_subtotals.pensioner_disregard_applied.to_f,
          total_liquid: @person_capital_subtotals.total_liquid.to_f,
          total_non_liquid: @person_capital_subtotals.total_non_liquid.to_f,
          total_vehicle: @person_capital_subtotals.total_vehicle.to_f,
          total_property: @person_capital_subtotals.total_property.to_f,
          total_mortgage_allowance: @person_capital_subtotals.total_mortgage_allowance.to_f,
          total_capital: @person_capital_subtotals.total_capital.to_f,
          subject_matter_of_dispute_disregard: @person_capital_subtotals.subject_matter_of_dispute_disregard.to_f,
          assessed_capital: @person_capital_subtotals.assessed_capital.to_f,
          total_capital_with_smod: @person_capital_subtotals.total_capital_with_smod,
          disputed_non_property_disregard: @person_capital_subtotals.disputed_non_property_disregard,
        }
      end
    end
  end
end
