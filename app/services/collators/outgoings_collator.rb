module Collators
  class OutgoingsCollator
    Result = Data.define(:dependant_allowance, :child_care, :housing_costs, :legal_aid_bank, :maintenance_out_bank,
                         :lone_parent_allowance, :pension_contribution, :housing_benefit) do
      def self.blank
        new(dependant_allowance: DependantsAllowanceCollator::Result.blank,
            child_care: ChildcareCollator::Result.blank,
            legal_aid_bank: 0,
            maintenance_out_bank: 0,
            housing_costs: HousingCostsCollator::Result.blank,
            lone_parent_allowance: 0,
            housing_benefit: 0,
            pension_contribution: Calculators::PensionContributionCalculator::Result.blank)
      end
    end

    class << self
      def call(submission_date:, person:, gross_income_summary:,
               outgoings:,
               eligible_for_childcare:, allow_negative_net:,
               total_gross_income:, state_benefits:)
        child_care = if eligible_for_childcare
                       Collators::ChildcareCollator.call(
                         cash_transactions: gross_income_summary.cash_transactions(:debit, :child_care),
                         childcare_outgoings: outgoings.select { |o| o.instance_of?(Outgoings::Childcare) },
                       )
                     else
                       Collators::ChildcareCollator::Result.blank
                     end

        dependant_allowance = Collators::DependantsAllowanceCollator.call(dependants: person.dependants,
                                                                          submission_date:)

        lone_parent_allowance = if person.single?
                                  Calculators::LoneParentAllowanceCalculator.call(dependants: person.dependants, submission_date:)
                                else
                                  0
                                end

        maintenance_out_bank = Collators::MaintenanceCollator.call(outgoings.select { |o| o.instance_of?(Outgoings::Maintenance) })

        housing_benefit = HousingBenefitsCollator.call(gross_income_summary:, state_benefits:)

        housing_costs = Collators::HousingCostsCollator.call(housing_cost_outgoings: outgoings.select { |o| o.instance_of?(Outgoings::HousingCost) },
                                                             gross_income_summary:,
                                                             person:,
                                                             housing_benefit:,
                                                             submission_date:,
                                                             allow_negative_net:)

        legal_aid_bank = Collators::LegalAidCollator.call(outgoings.select { |o| o.instance_of?(Outgoings::LegalAid) })

        pension_contribution = Calculators::PensionContributionCalculator.call(
          outgoings: outgoings.select { |o| o.instance_of?(Outgoings::PensionContribution) },
          cash_transactions: gross_income_summary.cash_transactions(:debit, :pension_contribution),
          regular_transactions: gross_income_summary.regular_transactions.pension_contributions,
          total_gross_income:,
          submission_date:,
        )

        Result.new(dependant_allowance:,
                   child_care:,
                   housing_costs:,
                   legal_aid_bank:,
                   housing_benefit:,
                   maintenance_out_bank:,
                   lone_parent_allowance:,
                   pension_contribution:)
      end
    end
  end
end
