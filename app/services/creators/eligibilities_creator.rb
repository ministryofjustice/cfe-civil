module Creators
  class EligibilitiesCreator
    class << self
      def call(assessment)
        DisposableIncomeEligibilityCreator.call(assessment)
        CapitalEligibilityCreator.call(assessment)
        AssessmentEligibilityCreator.call(assessment)
      end
    end
  end
end
