module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:, vehicles:)
        liquid_capital_result = Assessors::LiquidCapitalAssessor.call(capital_summary.liquid_capital_items)
        non_liquid_capital_result = Assessors::NonLiquidCapitalAssessor.call(capital_summary.non_liquid_capital_items)

        properties = Assessors::PropertyAssessor.call(submission_date:,
                                                      properties: capital_summary.properties,
                                                      smod_cap: maximum_subject_matter_of_dispute_disregard,
                                                      level_of_help:)
        property_smod = properties.sum(&:smod_allowance)
        assessed_vehicles = Assessors::VehicleAssessor.call(vehicles, submission_date)

        PersonCapitalSubtotals.new(
          vehicles: assessed_vehicles,
          properties:,
          liquid_capital_items: liquid_capital_result,
          non_liquid_capital_items: non_liquid_capital_result,
          total_mortgage_allowance: property_maximum_mortgage_allowance_threshold(submission_date),
          pensioner_capital_disregard:,
          disputed_property_disregard: property_smod,
          maximum_smod_disregard: maximum_subject_matter_of_dispute_disregard - property_smod,
        )
      end

      def property_maximum_mortgage_allowance_threshold(submission_date)
        Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
      end
    end
  end
end
