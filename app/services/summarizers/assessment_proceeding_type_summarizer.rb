module Summarizers
  class AssessmentProceedingTypeSummarizer
    # this class examines the assessment results on capital, gross_income and
    # disposable income _eligibility records for the specified proceeding type code
    # and updates the corresponding assessment_eligibility records with an overall
    # result for that proceeding type
    #
    class AssessmentError < StandardError; end

    class << self
      def call(assessment:, proceeding_type_code:, receives_qualifying_benefit:, receives_asylum_support:,
               gross_income_assessment_result:, disposable_income_result:)
        assessment_eligibility(assessment, proceeding_type_code).update!(
          assessment_result: result(assessment:, receives_qualifying_benefit:, receives_asylum_support:, proceeding_type_code:,
                                    gross_income_assessment_result:, disposable_income_result:),
        )
      end

    private

      def result(assessment:, receives_qualifying_benefit:, receives_asylum_support:, proceeding_type_code:, gross_income_assessment_result:, disposable_income_result:)
        if this_is_an_immigration_or_asylum_case?(proceeding_type_code) && receives_asylum_support
          "eligible"
        elsif receives_qualifying_benefit
          passported_assessment assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result
        else
          gross_income_assessment assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result
        end
      end

      def this_is_an_immigration_or_asylum_case?(proceeding_type_code)
        proceeding_type_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES)
      end

      def passported_assessment(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result)
        raise AssessmentError, "Assessment not complete: Capital assessment still pending" if capital_result(assessment, proceeding_type_code).to_s == "pending"
        raise AssessmentError, "Invalid assessment status: for passported applicant" if assessment.applicant_disposable_income_summary && disposable_income_result.to_s != "pending"
        raise AssessmentError, "Invalid assessment status: for passported applicant" if assessment.applicant_gross_income_summary && gross_income_assessment_result.to_s != "pending"

        capital_result assessment, proceeding_type_code
      end

      def gross_income_assessment(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result)
        raise AssessmentError, "Assessment not complete: Gross Income assessment still pending" if gross_income_assessment_result.to_s == "pending"

        return "ineligible" if gross_income_assessment_result.to_s == "ineligible"

        disposble_income_assessment assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result
      end

      def disposble_income_assessment(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result)
        raise AssessmentError, "Assessment not complete: Disposable Income assessment still pending" if disposable_income_result.to_s == "pending"

        return disposable_income_result if disposable_income_result.to_s == "ineligible"

        capital_assessment assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result
      end

      def capital_assessment(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result)
        raise AssessmentError, "Assessment not complete: Capital assessment still pending" if capital_result(assessment, proceeding_type_code).to_s == "pending"

        if capital_result(assessment, proceeding_type_code).to_s == "ineligible"
          "ineligible"
        elsif "contribution_required".in?(combined_result(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result))
          "contribution_required"
        else
          "eligible"
        end
      end

      def assessment_eligibility(assessment, proceeding_type_code)
        assessment.eligibilities.find_by(proceeding_type_code:)
      end

      def capital_eligibility(assessment, proceeding_type_code)
        assessment.applicant_capital_summary.eligibilities.find_by(proceeding_type_code:)
      end

      def combined_result(assessment, proceeding_type_code, gross_income_assessment_result, disposable_income_result)
        [gross_income_assessment_result, disposable_income_result, capital_result(assessment, proceeding_type_code)].map(&:to_s)
      end

      def capital_result(assessment, proceeding_type_code)
        capital_eligibility(assessment, proceeding_type_code).assessment_result
      end
    end
  end
end
