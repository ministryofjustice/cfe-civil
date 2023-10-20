module GrossIncome
  class Base
    attr_reader :applicant_gross_income_subtotals, :partner_gross_income_subtotals

    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:)
      @applicant_gross_income_subtotals = applicant_gross_income_subtotals
      @partner_gross_income_subtotals = partner_gross_income_subtotals
    end
  end
end
