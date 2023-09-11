module Creators
  class EligibilitiesCreator
    class << self
      def call(assessment)
        AssessmentEligibilityCreator.call(assessment)
      end
    end
  end
end
