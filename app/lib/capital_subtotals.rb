class CapitalSubtotals
  class << self
    def unassessed(applicant:, partner:, submission_date:)
      new(
        applicant_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: assessed_vehicles(applicant, submission_date)),
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: assessed_vehicles(partner, submission_date)),
        capital_contribution: 0,
        combined_assessed_capital: 0,
      )
    end

    def assessed_vehicles(person, submission_date)
      vehicles = person&.vehicles || []
      Assessors::VehicleAssessor.call(vehicles, submission_date)
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
