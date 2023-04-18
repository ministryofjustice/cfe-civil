module Decorators
  module V5
    class ApplicantCapitalResultDecorator < CapitalResultDecorator
      def initialize(summary:, person_capital_subtotals:, capital_contribution:, combined_assessed_capital:)
        super(summary, person_capital_subtotals)
        @capital_contribution = capital_contribution
        @combined_assessed_capital = combined_assessed_capital
      end

      def as_json
        super.merge(proceeding_types:,
                    capital_contribution: @capital_contribution,
                    pensioner_capital_disregard: @person_capital_subtotals.pensioner_capital_disregard.to_f,
                    combined_assessed_capital:)
      end

    private

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary.eligibilities, @summary.assessment.proceeding_types).as_json
      end

      def combined_assessed_capital
        @combined_assessed_capital.to_f
      end
    end
  end
end
