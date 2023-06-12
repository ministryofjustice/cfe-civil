class CapitalSubtotals
  class << self
    def blank
      new(applicant_capital_subtotals: PersonCapitalSubtotals.blank,
          partner_capital_subtotals: PersonCapitalSubtotals.blank,
          capital_contribution: 0,
          combined_assessed_capital: 0)
    end

    def unassessed(applicant:, partner:)
      new(
        applicant_capital_subtotals: PersonCapitalSubtotals.unassessed(disputed_vehicles: unassessed_vehicles(applicant, disputed: true), non_disputed_vehicles: unassessed_vehicles(applicant, disputed: false), properties: []),
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(disputed_vehicles: unassessed_vehicles(partner, disputed: true), non_disputed_vehicles: unassessed_vehicles(partner, disputed: false), properties: []),
        capital_contribution: 0,
        combined_assessed_capital: 0,
      )
    end

    def unassessed_vehicles(person, disputed: true)
      vehicles = person&.vehicles || []
      (disputed ? vehicles.select(&:subject_matter_of_dispute) : vehicles.reject(&:subject_matter_of_dispute)).map do |vehicle|
        Assessors::VehicleAssessor::VehicleData.new(vehicle:, result: Assessors::VehicleAssessor::Result.new(assessed_value: 0, included_in_assessment: false))
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
