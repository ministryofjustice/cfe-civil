module Collators
  class OutgoingsCollator
    Result = Data.define(:dependant_allowance, :child_care, :housing_costs, :legal_aid_bank, :maintenance_out_bank, :lone_parent_allowance, :pension_contribution) do
      def self.blank
        new(dependant_allowance: DependantsAllowanceCollator::Result.blank,
            child_care: ChildcareCollator::Result.blank,
            legal_aid_bank: 0,
            maintenance_out_bank: 0,
            housing_costs: HousingCostsCollator::Result.blank,
            lone_parent_allowance: 0,
            pension_contribution: Calculators::PensionContributionCalculator::Result.blank)
      end
    end

    class << self
      def call(submission_date:, person:, gross_income_summary:, disposable_income_summary:, eligible_for_childcare:, allow_negative_net:, total_gross_income:)
        child_care = Collators::ChildcareCollator.call(cash_transactions: gross_income_summary.cash_transactions(:debit, :child_care),
                                                       childcare_outgoings: disposable_income_summary.childcare_outgoings,
                                                       eligible_for_childcare:)

        dependant_allowance = Collators::DependantsAllowanceCollator.call(dependants: person.dependants,
                                                                          submission_date:)

        lone_parent_allowance = if person.single?
                                  Calculators::LoneParentAllowanceCalculator.call(dependants: person.dependants, submission_date:)
                                else
                                  0
                                end

        maintenance_out_bank = Collators::MaintenanceCollator.call(disposable_income_summary.maintenance_outgoings)

        housing_costs = Collators::HousingCostsCollator.call(housing_cost_outgoings: disposable_income_summary.housing_cost_outgoings,
                                                             gross_income_summary:,
                                                             person:,
                                                             submission_date:,
                                                             allow_negative_net:)

        legal_aid_bank = Collators::LegalAidCollator.call(disposable_income_summary.legal_aid_outgoings)

        pension_contribution = Calculators::PensionContributionCalculator.call(
          outgoings: disposable_income_summary.pension_contribution_outgoings,
          cash_transactions: gross_income_summary.cash_transactions(:debit, :pension_contribution),
          regular_transactions: gross_income_summary.regular_transactions.pension_contributions,
          total_gross_income:,
          submission_date:,
        )

        Result.new(dependant_allowance:,
                   child_care:,
                   housing_costs:,
                   legal_aid_bank:,
                   maintenance_out_bank:,
                   lone_parent_allowance:,
                   pension_contribution:)
      end
    end
  end
end
