module GrossIncome
  class Subtotals < Base
    # This object has the dependants required to display eligibilities, so has to expose them
    # (it's applicant + partner when partner present, just applicant otherwise)
    attr_reader :dependants

    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                   dependants:, submission_date:, level_of_help:)
      super(applicant_gross_income_subtotals:, partner_gross_income_subtotals:)

      @submission_date = submission_date
      @dependants = dependants
      @level_of_help = level_of_help
    end

    def assessed?
      true
    end

    def combined_monthly_gross_income
      @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
    end

    def ineligible?(proceeding_types)
      !eligible? proceeding_types
    end

    def below_the_lower_controlled_threshold?
      threshold = Creators::GrossIncomeEligibilityCreator.lower_threshold(level_of_help: @level_of_help, submission_date: @submission_date)
      threshold && combined_monthly_gross_income < threshold
    end

  private

    def assessment_results(proceeding_types)
      Creators::GrossIncomeEligibilityCreator.assessment_results dependants: @dependants,
                                                                 proceeding_types:,
                                                                 submission_date: @submission_date,
                                                                 total_gross_income: combined_monthly_gross_income
    end

    def eligible?(proceeding_types)
      Utilities::ResultSummarizer.call(assessment_results(proceeding_types).values).in? %i[eligible partially_eligible]
    end
  end
end
