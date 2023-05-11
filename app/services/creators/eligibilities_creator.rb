module Creators
  class EligibilitiesCreator
    def self.call(assessment)
      GrossIncomeEligibilityCreator.call(assessment.gross_income_summary,
                                         assessment.client_dependants + assessment.partner_dependants,
                                         assessment.proceeding_types,
                                         assessment.submission_date)
      DisposableIncomeEligibilityCreator.call(assessment)
      CapitalEligibilityCreator.call(assessment)
      AssessmentEligibilityCreator.call(assessment)
    end
  end
end
