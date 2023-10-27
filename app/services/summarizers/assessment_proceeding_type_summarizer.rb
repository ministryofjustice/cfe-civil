module Summarizers
  class AssessmentProceedingTypeSummarizer
    # this class examines the assessment results on capital, gross_income and
    # disposable income _eligibility records for the specified proceeding type code
    # and updates the corresponding assessment_eligibility records with an overall
    # result for that proceeding type
    #
    class AssessmentError < StandardError; end

    class << self
      include AssessmentEligibility

      def call(proceeding_type_code:, receives_qualifying_benefit:, receives_asylum_support:, submission_date:,
               gross_income_assessment_result:, disposable_income_result:, capital_assessment_result:)
        if non_means_tested?(proceeding_type_codes: [proceeding_type_code], receives_asylum_support:, submission_date:)
          "eligible"
        elsif receives_qualifying_benefit
          passported_assessment gross_income_assessment_result, disposable_income_result, capital_assessment_result
        else
          gross_income_assessment gross_income_assessment_result, disposable_income_result, capital_assessment_result
        end
      end

    private

      def this_is_an_immigration_or_asylum_case?(proceeding_type_code)
        proceeding_type_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES)
      end

      def passported_assessment(gross_income_assessment_result, disposable_income_result, capital_result)
        raise AssessmentError, "Assessment not complete: Capital assessment still pending" if capital_result.to_s == "pending"
        raise AssessmentError, "Invalid assessment status: for passported applicant" if disposable_income_result.to_s != "pending"
        raise AssessmentError, "Invalid assessment status: for passported applicant" if gross_income_assessment_result.to_s != "pending"

        capital_result
      end

      def gross_income_assessment(gross_income_assessment_result, disposable_income_result, capital_result)
        case gross_income_assessment_result.to_s
        when "pending"
          raise AssessmentError, "Assessment not complete: Gross Income assessment still pending"
        when "ineligible"
          "ineligible"
        else
          disposble_income_assessment gross_income_assessment_result, disposable_income_result, capital_result
        end
      end

      def disposble_income_assessment(gross_income_assessment_result, disposable_income_result, capital_result)
        case disposable_income_result.to_s
        when "pending"
          raise AssessmentError, "Assessment not complete: Disposable Income assessment still pending"
        when "ineligible"
          "ineligible"
        else
          capital_assessment gross_income_assessment_result, disposable_income_result, capital_result
        end
      end

      def capital_assessment(gross_income_assessment_result, disposable_income_result, capital_result)
        raise AssessmentError, "Assessment not complete: Capital assessment still pending" if capital_result.to_s == "pending"

        if capital_result.to_s == "ineligible"
          "ineligible"
        elsif "contribution_required".in?(combined_result(gross_income_assessment_result, disposable_income_result, capital_result))
          "contribution_required"
        else
          "eligible"
        end
      end

      def combined_result(gross_income_assessment_result, disposable_income_result, capital_result)
        [gross_income_assessment_result, disposable_income_result, capital_result].map(&:to_s)
      end
    end
  end
end
