module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, pensioner_capital_disregard:,
               maximum_subject_matter_of_dispute_disregard:, level_of_help:, capitals_data:)
        liquid_capital_result = Calculators::LiquidCapitalCalculator.call(capitals_data.liquid_capital_items)
        non_liquid_capital_result = Calculators::NonLiquidCapitalCalculator.call(capitals_data.non_liquid_capital_items)

        assessed_properties = Calculators::PropertyCalculator.call(submission_date:,
                                                                   main_home: capitals_data.main_home,
                                                                   additional_properties: capitals_data.additional_properties,
                                                                   smod_cap: maximum_subject_matter_of_dispute_disregard,
                                                                   level_of_help:)
        assessed_vehicles = Calculators::VehicleCalculator.call(capitals_data.vehicles, submission_date)

        PersonCapitalSubtotals.new(
          vehicles: assessed_vehicles,
          properties: assessed_properties,
          liquid_capital_items: liquid_capital_result,
          non_liquid_capital_items: non_liquid_capital_result,
          total_mortgage_allowance: property_maximum_mortgage_allowance_threshold(submission_date),
          pensioner_capital_disregard:,
          maximum_subject_matter_of_dispute_disregard:,
        )
      end

      def property_maximum_mortgage_allowance_threshold(submission_date)
        Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
      end
    end
  end
end
