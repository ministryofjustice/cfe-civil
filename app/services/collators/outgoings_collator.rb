module Collators
  class OutgoingsCollator
    Result = Data.define(:dependant_allowance, :child_care, :housing_costs, :legal_aid_bank, :maintenance_out_bank,
                         :lone_parent_allowance, :pension_contribution, :housing_benefit, :council_tax, :priority_debt_repayment) do
      def self.blank
        new(dependant_allowance: DependantsAllowanceCollator::Result.blank,
            child_care: ChildcareCollator::Result.blank,
            legal_aid_bank: 0,
            maintenance_out_bank: 0,
            housing_costs: HousingCostsCollator::Result.blank,
            lone_parent_allowance: 0,
            housing_benefit: 0,
            pension_contribution: Calculators::PensionContributionCalculator::Result.blank,
            council_tax: Calculators::CouncilTaxCalculator::Result.blank,
            priority_debt_repayment: Calculators::PriorityDebtRepaymentCalculator::Result.blank)
      end
    end

    class << self
      def call(submission_date:, person:,
               outgoings:, cash_transactions:,
               eligible_for_childcare:, allow_negative_net:,
               total_gross_income:, state_benefits:, regular_transactions:)
        child_care = if eligible_for_childcare
                       Collators::ChildcareCollator.call(
                         cash_transactions: cash_transactions.select(&:child_care_payment?),
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

        housing_benefit = HousingBenefitsCollator.call(regular_transactions:, state_benefits:)

        housing_costs = Collators::HousingCostsCollator.call(housing_cost_outgoings: outgoings.select { |o| o.instance_of?(Outgoings::HousingCost) },
                                                             regular_transactions:,
                                                             person:,
                                                             housing_benefit:,
                                                             cash_transactions:,
                                                             submission_date:,
                                                             allow_negative_net:)

        legal_aid_bank = Collators::LegalAidCollator.call(outgoings.select { |o| o.instance_of?(Outgoings::LegalAid) })

        pension_contribution = Calculators::PensionContributionCalculator.call(
          outgoings: outgoings.select { |o| o.instance_of?(Outgoings::PensionContribution) },
          cash_transactions: cash_transactions.select(&:pension_contribution?),
          regular_transactions: regular_transactions.select(&:pension_contribution?),
          total_gross_income:,
          submission_date:,
        )

        council_tax = Calculators::CouncilTaxCalculator.call(
          outgoings: outgoings.select { |o| o.instance_of?(Outgoings::CouncilTax) },
          cash_transactions: cash_transactions.select(&:council_tax_payment?),
          regular_transactions: regular_transactions.select(&:council_tax_payment?),
          submission_date:,
        )

        priority_debt_repayment = Calculators::PriorityDebtRepaymentCalculator.call(
          outgoings: outgoings.select { |o| o.instance_of?(Outgoings::PriorityDebtRepayment) },
          cash_transactions: cash_transactions.select(&:priority_debt_repayment?),
          regular_transactions: regular_transactions.select(&:priority_debt_repayment?),
          submission_date:,
        )

        Result.new(dependant_allowance:,
                   child_care:,
                   housing_costs:,
                   legal_aid_bank:,
                   housing_benefit:,
                   maintenance_out_bank:,
                   lone_parent_allowance:,
                   pension_contribution:,
                   council_tax:,
                   priority_debt_repayment:)
      end
    end
  end
end
