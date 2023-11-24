# Convert each regular outgoing to monthly and sum together in
# <category>_all_sources with any pre-existing values from other
# transactions (cash typically). Also, except for :rent_or_mortgate**,
# increment the total_outgoings_and_allowances and decrement the total_disposable_income.
#
# ** :rent_or_mortgage that has already been added to totals by the
# HousingCostCollator/HousingCostCalculator and DisposableIncomeCollator :(
#
# *§ :child_care should not be added unless eligible (see Collators::ChildcareCollator)
# to emulate behaviour for bank and cash transactions.
#
module Collators
  class RegularOutgoingsCollator
    Result = Data.define(:child_care_regular, :legal_aid_regular, :maintenance_out_regular) do
      def self.blank
        new(child_care_regular: 0, legal_aid_regular: 0, maintenance_out_regular: 0)
      end
    end

    class << self
      def call(regular_transactions:, eligible_for_childcare:)
        childcare_monthly_amount = if eligible_for_childcare # see *§ above
                                     regular_amount_for(regular_transactions.select(&:child_care_payment?))
                                   else
                                     0
                                   end

        Result.new(child_care_regular: childcare_monthly_amount,
                   legal_aid_regular: regular_amount_for(regular_transactions.select(&:legal_aid_payment?)),
                   maintenance_out_regular: regular_amount_for(regular_transactions.select(&:maintenance_out_payment?)))
      end

      def regular_amount_for(txns)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(txns)
      end
    end
  end
end
