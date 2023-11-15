module GrossIncome
  class Subtotals < Base
    def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals:,
                   dependants:, submission_date:, level_of_help:)
      super(applicant_gross_income_subtotals:, partner_gross_income_subtotals:)

      @submission_date = submission_date
      @dependants = dependants
      @level_of_help = level_of_help
    end

    def combined_monthly_gross_income
      @applicant_gross_income_subtotals.total_gross_income + @partner_gross_income_subtotals.total_gross_income
    end

    def ineligible?(proceeding_types:, submission_date:)
      !eligible? proceeding_types:, submission_date:
    end

    def eligibilities(proceeding_types)
      Creators::GrossIncomeEligibilityCreator.call dependants: @dependants,
                                                   proceeding_types:,
                                                   level_of_help: @level_of_help,
                                                   submission_date: @submission_date,
                                                   total_gross_income: combined_monthly_gross_income
    end

  private

    def eligible?(proceeding_types:, submission_date:)
      Utilities::ResultSummarizer.call(assessment_results(proceeding_types:, submission_date:).values).in? %i[eligible partially_eligible]
    end

    def assessment_results(proceeding_types:, submission_date:)
      Creators::GrossIncomeEligibilityCreator.assessment_results dependants: @dependants,
                                                                 proceeding_types:,
                                                                 submission_date:,
                                                                 total_gross_income: combined_monthly_gross_income
    end
  end
end
