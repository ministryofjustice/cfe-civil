module Assessors
  class PropertyAssessor
    Result = Struct.new(:transaction_allowance,
                        :net_value,
                        :net_equity,
                        :property,
                        :main_home_equity_disregard,
                        :assessed_equity,
                        :smod_allowance,
                        keyword_init: true) do
      delegate :main_home, :value, :subject_matter_of_dispute,
               :outstanding_mortgage, :percentage_owned, :shared_with_housing_assoc, to: :property
    end

    Disregard = Data.define(:result, :applied)

    class << self
      def call(submission_date:, properties:, level_of_help:, smod_cap:)
        remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)

        (properties.select(&:main_home) + properties.reject(&:main_home)).map do |property|
          allowable_outstanding_mortgage = calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
          remaining_mortgage_allowance -= allowable_outstanding_mortgage

          transaction_allowance_cap = property_transaction_allowance_cap(property, level_of_help, submission_date)
          equity = property.value - allowable_outstanding_mortgage
          transaction_allowance = Utilities::NumberUtilities.negative_to_zero [equity, transaction_allowance_cap].min
          net_value = equity - transaction_allowance
          net_equity = calculate_net_equity(property, net_value)

          smod_disregard = if property.subject_matter_of_dispute
                             apply_disregard(net_equity, smod_cap)
                           else
                             Disregard.new(result: net_equity, applied: 0)
                           end
          smod_cap -= smod_disregard.applied

          equity_disregard = apply_disregard smod_disregard.result, main_home_equity_disregard_cap(property, submission_date)

          Result.new(transaction_allowance:,
                     net_value:,
                     net_equity:,
                     main_home_equity_disregard: equity_disregard.applied,
                     property:,
                     smod_allowance: smod_disregard.applied,
                     assessed_equity: equity_disregard.result).freeze
        end
      end

    private

      def apply_disregard(equity, disregard)
        equity_after_disregard = Utilities::NumberUtilities.negative_to_zero equity - disregard
        Disregard.new(result: equity_after_disregard, applied: equity - equity_after_disregard)
      end

      def calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
        property.outstanding_mortgage > remaining_mortgage_allowance ? remaining_mortgage_allowance : property.outstanding_mortgage
      end

      def main_home_equity_disregard_cap(property, submission_date)
        property_type = property.main_home ? :main_home : :additional_property
        Threshold.value_for(:property_disregard, at: submission_date)[property_type]
      end

      def property_transaction_allowance_cap(property, level_of_help, submission_date)
        level_of_help == "controlled" ? 0.0 : (property.value * notional_transaction_cost_pctg(submission_date)).round(2)
      end

      def notional_transaction_cost_pctg(submission_date)
        Threshold.value_for(:property_notional_sale_costs_percentage, at: submission_date) / 100.0
      end

      def calculate_net_equity(property, net_value)
        if property.shared_with_housing_assoc
          (net_value - housing_association_share(property)).round(2)
        else
          (net_value * shared_ownership_percentage(property)).round(2)
        end
      end

      def housing_association_share(property)
        property.value * (1 - shared_ownership_percentage(property))
      end

      def shared_ownership_percentage(property)
        property.percentage_owned / 100.0
      end
    end
  end
end
