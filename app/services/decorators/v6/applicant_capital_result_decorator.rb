module Decorators
  module V6
    class ApplicantCapitalResultDecorator < CapitalResultDecorator
      def initialize(applicant_capital_subtotals:, partner_capital_subtotals:, capital_contribution:,
                     combined_assessed_capital:, eligibilities:)
        super(applicant_capital_subtotals)
        @capital_contribution = capital_contribution
        @combined_assessed_capital = combined_assessed_capital
        @partner_capital_subtotals = partner_capital_subtotals
        @eligibilities = eligibilities
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
        ProceedingTypesResultDecorator.new(@eligibilities).as_json
      end

      def combined_assessed_capital
        @combined_assessed_capital.to_f
      end
    end
  end
end
