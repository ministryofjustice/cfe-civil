module Creators
  class RemarksCreator
    class << self
      def call(assessment:, applicant:, partner:, calculation_output:)
        # we can take the lower threshold from the first eligibility records as they are all the same
        # lower_capital_threshold = assessment.applicant_capital_summary.eligibilities.first.lower_threshold
        lower_capital_threshold = calculation_output.capital_subtotals.eligibilities.first.lower_threshold

        new_remarks = RemarkGenerators::Orchestrator.call(employments: applicant.employments,
                                                          gross_income_summary: assessment.applicant_gross_income_summary,
                                                          outgoings: applicant.outgoings,
                                                          liquid_capital_items: applicant.capitals_data.liquid_capital_items,
                                                          state_benefits: applicant.state_benefits,
                                                          lower_capital_threshold:,
                                                          child_care_bank: calculation_output.applicant_disposable_income_subtotals.child_care_bank,
                                                          assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        if partner.present?
          new_remarks += RemarkGenerators::Orchestrator.call(employments: partner.employments,
                                                             gross_income_summary: assessment.partner_gross_income_summary,
                                                             outgoings: partner.outgoings,
                                                             liquid_capital_items: partner.capitals_data.liquid_capital_items,
                                                             lower_capital_threshold:,
                                                             state_benefits: partner.state_benefits,
                                                             child_care_bank: calculation_output.partner_disposable_income_subtotals.child_care_bank,
                                                             assessed_capital: calculation_output.capital_subtotals.combined_assessed_capital)
        end
        assessment.add_remarks!(new_remarks)
      end
    end
  end
end
