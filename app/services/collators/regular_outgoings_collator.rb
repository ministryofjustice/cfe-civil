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
    Attrs = Data.define(:attrs, :child_care_regular, :rent_or_mortgage_regular)
    Result = Data.define(:child_care_regular, :rent_or_mortgage_regular) do
      def self.blank
        new(child_care_regular: 0, rent_or_mortgage_regular: 0)
      end
    end

    class << self
      def call(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:)
        attrs = disposable_income_attributes(disposable_income_summary:, eligible_for_childcare:, gross_income_summary:)
        disposable_income_summary.update!(attrs.attrs)
        Result.new(child_care_regular: attrs.child_care_regular, rent_or_mortgage_regular: attrs.rent_or_mortgage_regular)
      end

    private

      def outgoing_categories
        %i[maintenance_out legal_aid].freeze
      end

      def disposable_income_attributes(disposable_income_summary:, eligible_for_childcare:, gross_income_summary:)
        attrs = initialize_attributes disposable_income_summary

        outgoing_categories.each do |category|
          category_all_sources = "#{category}_all_sources".to_sym
          category_monthly_amount = regular_amount_for(gross_income_summary, category)

          attrs[category_all_sources] += category_monthly_amount

          attrs[:total_outgoings_and_allowances] += category_monthly_amount
          attrs[:total_disposable_income] -= category_monthly_amount
        end

        if eligible_for_childcare # see *§ above
          childcare_monthly_amount = regular_amount_for(gross_income_summary, :child_care)
          attrs[:total_outgoings_and_allowances] += childcare_monthly_amount
          attrs[:total_disposable_income] -= childcare_monthly_amount
        else
          childcare_monthly_amount = 0
        end

        # see ** above - already added to totals
        rent_or_mortgage_monthly_amount = regular_amount_for(gross_income_summary, :rent_or_mortgage)

        Attrs.new(attrs:, child_care_regular: childcare_monthly_amount,
                  rent_or_mortgage_regular: rent_or_mortgage_monthly_amount)
      end

      def regular_amount_for(gross_income_summary, category)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category:)
      end

      def initialize_attributes(disposable_income_summary)
        attrs = outgoing_categories.each_with_object({}) { |category, dict|
          dict["#{category}_all_sources"] = disposable_income_summary.send("#{category}_all_sources")
        }.symbolize_keys

        attrs[:total_outgoings_and_allowances] = disposable_income_summary.total_outgoings_and_allowances
        attrs[:total_disposable_income] = disposable_income_summary.total_disposable_income
        attrs
      end
    end
  end
end
