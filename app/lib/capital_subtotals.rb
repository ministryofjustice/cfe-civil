class CapitalSubtotals
  class << self
    def unassessed(applicant:, partner:)
      new(
        applicant_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(applicant), properties: unassessed_properties(applicant)),
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(partner), properties: unassessed_properties(partner)),
        capital_contribution: 0,
        combined_assessed_capital: 0,
      )
    end

    def unassessed_vehicles(person)
      (person&.vehicles || []).map do |vehicle|
        Assessors::VehicleAssessor::VehicleData.new(vehicle:, result: Assessors::VehicleAssessor::Result.new(assessed_value: 0, included_in_assessment: false))
      end
    end

    def unassessed_properties(person)
      (person&.properties || []).map do |property|
        result = Assessors::PropertyAssessor::Result.new(
          transaction_allowance: 0.0,
          net_value: 0.0,
          net_equity: 0.0,
          main_home_equity_disregard: 0.0,
          assessed_equity: 0.0,
          smod_allowance: 0,
          main_home: true,
          value: 0.0,
          subject_matter_of_dispute: false,
          outstanding_mortgage: 0.0,
          percentage_owned: 0.0,
          shared_with_housing_assoc: false,
        )
        Assessors::PropertyAssessor::PropertyData.new(property:, result:)
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
