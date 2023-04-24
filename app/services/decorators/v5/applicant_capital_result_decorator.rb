module Decorators
  module V5
    class ApplicantCapitalResultDecorator < CapitalResultDecorator
      def initialize(summary:, applicant_capital_subtotals:, partner_capital_subtotals:, capital_contribution:, combined_assessed_capital:)
        super(summary, applicant_capital_subtotals)
        @capital_contribution = capital_contribution
        @combined_assessed_capital = combined_assessed_capital
        @partner_capital_subtotals = partner_capital_subtotals
      end

      def as_json
        super.merge(proceeding_types:,
                    combined_disputed_capital:,
                    combined_non_disputed_capital:,
                    capital_contribution: @capital_contribution,
                    pensioner_capital_disregard: @person_capital_subtotals.pensioner_capital_disregard.to_f,
                    combined_assessed_capital:)
      end

    private

      def combined_disputed_capital
        @person_capital_subtotals.total_disputed_capital + @partner_capital_subtotals.total_disputed_capital
      end

      def combined_non_disputed_capital
        @person_capital_subtotals.total_non_disputed_capital + @partner_capital_subtotals.total_non_disputed_capital
      end

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary.eligibilities, @summary.assessment.proceeding_types).as_json
      end

      def combined_assessed_capital
        @combined_assessed_capital.to_f
      end
    end
  end
end
