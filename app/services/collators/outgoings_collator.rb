module Collators
  class OutgoingsCollator
    Result = Data.define(:dependant_allowance, :child_care, :rent_or_mortgage_bank, :housing_costs, :legal_aid_bank, :maintenance_out_bank, :lone_parent_allowance) do
      def self.blank
        new(dependant_allowance: DependantsAllowanceCollator::Result.blank,
            child_care: ChildcareCollator::Result.blank,
            rent_or_mortgage_bank: 0,
            legal_aid_bank: 0,
            maintenance_out_bank: 0,
            housing_costs: HousingCostsCollator::Result.blank,
            lone_parent_allowance: 0)
      end
    end

    class << self
      def call(submission_date:, person:, gross_income_summary:, disposable_income_summary:, eligible_for_childcare:, allow_negative_net:)
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

        Result.new(dependant_allowance:,
                   child_care:,
                   rent_or_mortgage_bank: housing_costs.gross_housing_costs_bank,
                   housing_costs:,
                   legal_aid_bank:,
                   maintenance_out_bank:,
                   lone_parent_allowance:)
      end
    end
  end
end
