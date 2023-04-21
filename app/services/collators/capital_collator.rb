module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_help:)
        liquid_capital = Assessors::LiquidCapitalAssessor.call(capital_summary)
        non_liquid_capital = Assessors::NonLiquidCapitalAssessor.call(capital_summary)
        properties = Calculators::PropertyCalculator.call(submission_date:,
                                                          properties: capital_summary.properties,
                                                          smod_cap: maximum_subject_matter_of_dispute_disregard,
                                                          level_of_help:)
        property_value = properties.sum(&:assessed_equity)
        property_smod = properties.sum(&:smod_allowance)
        vehicles = Assessors::VehicleAssessor.call(capital_summary.vehicles, submission_date)
        vehicle_value = vehicles.sum(&:value)
        non_property_smod_allowance = Calculators::SubjectMatterOfDisputeDisregardCalculator.new(
          capital_summary:,
          maximum_disregard: maximum_subject_matter_of_dispute_disregard - property_smod,
        ).value

        PersonCapitalSubtotals.new(
          total_liquid: liquid_capital,
          total_non_liquid: non_liquid_capital,
          total_vehicle: vehicle_value,
          total_mortgage_allowance: property_maximum_mortgage_allowance_threshold(submission_date),
          total_property: property_value,
          pensioner_capital_disregard:,
          disputed_non_property_disregard: non_property_smod_allowance,
          disputed_property_disregard: property_smod,
          main_home: capital_summary.main_home.present? ? PropertySubtotals.new(properties.detect(&:main_home)) : PropertySubtotals.new,
          additional_properties: properties.reject(&:main_home).map { |p| PropertySubtotals.new(p) },
        )
      end

      def property_maximum_mortgage_allowance_threshold(submission_date)
        Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
      end
    end
  end
end
