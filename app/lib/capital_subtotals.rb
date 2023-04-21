class CapitalSubtotals
  class << self
    def blank
      new(applicant_capital_subtotals: PersonCapitalSubtotals.blank,
          partner_capital_subtotals: PersonCapitalSubtotals.blank,
          capital_contribution: 0,
          combined_assessed_capital: 0)
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
