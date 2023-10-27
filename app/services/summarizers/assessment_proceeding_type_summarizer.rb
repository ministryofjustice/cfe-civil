module Summarizers
  class AssessmentProceedingTypeSummarizer
    # this class examines the assessment results on capital, gross_income and
    # disposable income _eligibility records for the specified proceeding type code
    # and updates the corresponding assessment_eligibility records with an overall
    # result for that proceeding type
    #
    class AssessmentError < StandardError; end

    class << self
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

      def non_means_tested?(proceeding_type_codes:, receives_asylum_support:, submission_date:)
        # skip proceeding types check if applicant receives asylum support after MTR go-live date
        if asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
          receives_asylum_support
        else
          proceeding_type_codes.map(&:to_sym).all? { _1.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } && receives_asylum_support
        end
      end

      def asylum_support_is_non_means_tested_for_all_matter_types?(submission_date)
        !!Threshold.value_for(:asylum_support_is_non_means_tested_for_all_matter_types, at: submission_date)
      end

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
