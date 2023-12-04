module Workflows
  class PersonWorkflow
    class << self
      def without_partner(assessment:, applicant:)
        result = Workflows::MainWorkflow.without_partner(submission_date: assessment.submission_date,
                                                         level_of_help: assessment.level_of_help,
                                                         proceeding_types: assessment.proceeding_types,
                                                         applicant:)
        lower_capital_threshold = Creators::CapitalEligibilityCreator.lower_capital_threshold(proceeding_types: assessment.proceeding_types,
                                                                                              level_of_help: assessment.level_of_help,
                                                                                              submission_date: assessment.submission_date)
        assessed_capital = result.calculation_output.combined_assessed_capital

        new_remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                          other_income_payments: applicant.other_income_payments,
                                                          cash_transactions: applicant.cash_transactions,
                                                          regular_transactions: applicant.regular_transactions,
                                                          submission_date: assessment.submission_date,
                                                          outgoings: applicant.outgoings,
                                                          liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                          state_benefits: applicant.state_benefits,
                                                          lower_capital_threshold:,
                                                          child_care_bank: result.calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                          assessed_capital:)
        workflow = Workflows::MainWorkflow::Result.new calculation_output: result.calculation_output,
                                                       remarks: new_remarks + result.remarks,
                                                       assessment_result: result.assessment_result
        er = EligibilityResults.without_partner(
          proceeding_types: assessment.proceeding_types,
          submission_date: assessment.submission_date,
          applicant:,
          level_of_help: assessment.level_of_help,
          controlled_legal_representation: assessment.controlled_legal_representation,
          not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
        )
        ResultAndEligibility.new workflow_result: workflow, eligibility_result: er
      end

      def with_partner(assessment:, applicant:, partner:)
        part = Workflows::MainWorkflow.with_partner(submission_date: assessment.submission_date,
                                                    level_of_help: assessment.level_of_help,
                                                    controlled_legal_representation: assessment.controlled_legal_representation,
                                                    not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
                                                    proceeding_types: assessment.proceeding_types,
                                                    applicant:,
                                                    partner:)
        lower_capital_threshold = Creators::CapitalEligibilityCreator.lower_capital_threshold(proceeding_types: assessment.proceeding_types,
                                                                                              level_of_help: assessment.level_of_help,
                                                                                              submission_date: assessment.submission_date)
        assessed_capital = part.calculation_output.combined_assessed_capital

        remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                      other_income_payments: applicant.other_income_payments,
                                                      cash_transactions: applicant.cash_transactions,
                                                      regular_transactions: applicant.regular_transactions,
                                                      submission_date: assessment.submission_date,
                                                      outgoings: applicant.outgoings,
                                                      liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                      state_benefits: applicant.state_benefits,
                                                      lower_capital_threshold:,
                                                      child_care_bank: part.calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                      assessed_capital:)
        remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                       other_income_payments: partner.other_income_payments,
                                                       cash_transactions: partner.cash_transactions,
                                                       regular_transactions: partner.regular_transactions,
                                                       submission_date: assessment.submission_date,
                                                       outgoings: partner.outgoings,
                                                       liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                       lower_capital_threshold:,
                                                       state_benefits: partner.state_benefits,
                                                       child_care_bank: part.calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                       assessed_capital:)
        workflow_result = Workflows::MainWorkflow::Result.new calculation_output: part.calculation_output,
                                                              assessment_result: part.assessment_result,
                                                              remarks: remarks + part.remarks
        er = EligibilityResults.with_partner(
          proceeding_types: assessment.proceeding_types,
          submission_date: assessment.submission_date,
          applicant:,
          level_of_help: assessment.level_of_help,
          controlled_legal_representation: assessment.controlled_legal_representation,
          not_aggregated_no_income_low_capital: assessment.not_aggregated_no_income_low_capital,
          partner:,
        )
        ResultAndEligibility.new workflow_result:, eligibility_result: er
      end
    end
  end
end
