module GrossIncome
  class Subtotals < Base
    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                   dependants:, submission_date:, level_of_help:)
      super(applicant_gross_income_subtotals:, partner_gross_income_subtotals:)

      @submission_date = submission_date
      @level_of_help = level_of_help
      @dependants = dependants
    end

    def combined_monthly_gross_income
      @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
    end

    def ineligible?(proceeding_types)
      !eligible? proceeding_types
    end

    def below_the_lower_controlled_threshold?
      @level_of_help == "controlled" && (combined_monthly_gross_income < (Threshold.value_for(:gross_income_lower_controlled, at: @submission_date) || 0))
    end

    def assessment_results(proceeding_types)
      Creators::GrossIncomeEligibilityCreator.assessment_results dependants: @dependants,
                                                                 proceeding_types:,
                                                                 submission_date: @submission_date,
                                                                 total_gross_income: combined_monthly_gross_income
    end

    def eligibilities(proceeding_types)
      Creators::GrossIncomeEligibilityCreator.call dependants: @dependants,
                                                   proceeding_types:,
                                                   submission_date: @submission_date,
                                                   total_gross_income: combined_monthly_gross_income,
                                                   level_of_help: @level_of_help
    end

  private

    def eligible?(proceeding_types)
      Utilities::ResultSummarizer.call(assessment_results(proceeding_types).values).in? %i[eligible partially_eligible]
    end
  end
end
