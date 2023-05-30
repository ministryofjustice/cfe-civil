module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:, vehicles:)
        disputed_liquid = capital_summary.liquid_capital_items.select(&:subject_matter_of_dispute)
        non_disputed_liquid = capital_summary.liquid_capital_items.reject(&:subject_matter_of_dispute)

        liquid_capital = Assessors::LiquidCapitalAssessor.call(non_disputed_liquid)
        smod_liquid_capital = Assessors::LiquidCapitalAssessor.call(disputed_liquid)

        disputed_non_liquid = capital_summary.non_liquid_capital_items.select(&:subject_matter_of_dispute)
        non_disputed_non_liquid = capital_summary.non_liquid_capital_items.reject(&:subject_matter_of_dispute)

        non_liquid_capital = Assessors::NonLiquidCapitalAssessor.call(non_disputed_non_liquid)
        smod_non_liquid_capital = Assessors::NonLiquidCapitalAssessor.call(disputed_non_liquid)

        properties = Calculators::PropertyCalculator.call(submission_date:,
                                                          properties: capital_summary.properties,
                                                          smod_cap: maximum_subject_matter_of_dispute_disregard,
                                                          level_of_help:)
        property_smod = properties.sum(&:smod_allowance)
        undisputed_vehicles = Assessors::VehicleAssessor.call(vehicles.reject(&:subject_matter_of_dispute), submission_date)
        smod_vehicles = Assessors::VehicleAssessor.call(vehicles.select(&:subject_matter_of_dispute), submission_date)
        vehicle_value = undisputed_vehicles.map(&:result).sum(&:assessed_value)
        smod_vehicle_value = smod_vehicles.map(&:result).sum(&:assessed_value)
        non_property_smod_allowance = Calculators::SubjectMatterOfDisputeDisregardCalculator.call(
          disputed_capital_items: disputed_liquid + disputed_non_liquid,
          disputed_vehicles: smod_vehicles.map(&:result),
          maximum_disregard: maximum_subject_matter_of_dispute_disregard - property_smod,
        )

        PersonCapitalSubtotals.new(
          total_liquid: liquid_capital + smod_liquid_capital,
          total_non_liquid: non_liquid_capital + smod_non_liquid_capital,
          non_disputed_vehicles: undisputed_vehicles,
          disputed_vehicles: smod_vehicles,
          total_mortgage_allowance: property_maximum_mortgage_allowance_threshold(submission_date),
          pensioner_capital_disregard:,
          disputed_non_property_disregard: non_property_smod_allowance,
          disputed_property_disregard: property_smod,
          properties:,
          non_disputed_non_property_capital: liquid_capital + non_liquid_capital + vehicle_value,
          disputed_non_property_capital: smod_liquid_capital + smod_non_liquid_capital + smod_vehicle_value - non_property_smod_allowance,
        )
      end

      def property_maximum_mortgage_allowance_threshold(submission_date)
        Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
      end
    end
  end
end
