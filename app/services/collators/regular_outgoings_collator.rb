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
    Attrs = Data.define(:attrs, :child_care_regular, :rent_or_mortgage_regular, :legal_aid_regular)
    Result = Data.define(:child_care_regular, :rent_or_mortgage_regular, :legal_aid_regular) do
      def self.blank
        new(child_care_regular: 0, rent_or_mortgage_regular: 0, legal_aid_regular: 0)
      end
    end

    class << self
      def call(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:)
        attrs = disposable_income_attributes(disposable_income_summary:, eligible_for_childcare:, gross_income_summary:)
        disposable_income_summary.update!(attrs.attrs)
        Result.new(child_care_regular: attrs.child_care_regular,
                   rent_or_mortgage_regular: attrs.rent_or_mortgage_regular,
                   legal_aid_regular: attrs.legal_aid_regular)
      end

    private

      def disposable_income_attributes(disposable_income_summary:, eligible_for_childcare:, gross_income_summary:)
        attrs = {
          maintenance_out_all_sources: disposable_income_summary.maintenance_out_all_sources,
          total_outgoings_and_allowances: disposable_income_summary.total_outgoings_and_allowances,
          total_disposable_income: disposable_income_summary.total_disposable_income,
        }

        maintenance_out_monthly_amount = regular_amount_for(gross_income_summary, :maintenance_out)
        attrs[:maintenance_out_all_sources] += maintenance_out_monthly_amount

        attrs[:total_outgoings_and_allowances] += maintenance_out_monthly_amount
        attrs[:total_disposable_income] -= maintenance_out_monthly_amount

        if eligible_for_childcare # see *§ above
          childcare_monthly_amount = regular_amount_for(gross_income_summary, :child_care)
          attrs[:total_outgoings_and_allowances] += childcare_monthly_amount
          attrs[:total_disposable_income] -= childcare_monthly_amount
        else
          childcare_monthly_amount = 0
        end

        # see ** above - already added to totals
        rent_or_mortgage_monthly_amount = regular_amount_for(gross_income_summary, :rent_or_mortgage)

        legal_aid_monthly_amount = regular_amount_for(gross_income_summary, :legal_aid)
        attrs[:total_outgoings_and_allowances] += legal_aid_monthly_amount
        attrs[:total_disposable_income] -= legal_aid_monthly_amount

        Attrs.new(attrs:, child_care_regular: childcare_monthly_amount,
                  rent_or_mortgage_regular: rent_or_mortgage_monthly_amount,
                  legal_aid_regular: legal_aid_monthly_amount)
      end

      def regular_amount_for(gross_income_summary, category)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category:)
      end
    end
  end
end
