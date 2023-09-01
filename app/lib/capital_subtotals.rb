class CapitalSubtotals
  class << self
    def unassessed(applicant_capitals:, partner_capitals:)
      new(
        applicant_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(applicant_capitals.vehicles), properties: unassessed_properties(applicant_capitals.properties)),
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(partner_capitals&.vehicles), properties: unassessed_properties(partner_capitals&.properties)),
        capital_contribution: 0,
        combined_assessed_capital: 0,
      )
    end

    def unassessed_vehicles(vehicles)
      (vehicles || []).map do |vehicle|
        Assessors::VehicleAssessor::VehicleData.new(vehicle:, result: Assessors::VehicleAssessor::Result.new(assessed_value: 0, included_in_assessment: false))
      end
    end

    def unassessed_properties(properties)
      (properties || []).map do |property|
        Assessors::PropertyAssessor::PropertyData.new(property:, result: Assessors::PropertyAssessor::Result.blank)
      end
    end
  end

  def initialize(applicant_capital_subtotals:, partner_capital_subtotals:, capital_contribution:, combined_assessed_capital:)
    @applicant_capital_subtotals = applicant_capital_subtotals
    @partner_capital_subtotals = partner_capital_subtotals
    @capital_contribution = capital_contribution
    @combined_assessed_capital = combined_assessed_capital
  end

  attr_reader :applicant_capital_subtotals, :partner_capital_subtotals, :capital_contribution, :combined_assessed_capital
end
