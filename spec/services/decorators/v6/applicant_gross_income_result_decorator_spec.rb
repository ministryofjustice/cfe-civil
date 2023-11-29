require "rails_helper"

module Decorators
  module V6
    RSpec.describe ApplicantGrossIncomeResultDecorator do
      let(:unlimited) { 999_999_999_999.0 }
      let(:proceeding_types) do
        [
          build(:proceeding_type, :with_waived_thresholds, ccms_code: "DA002", client_involvement_type: "A"),
          build(:proceeding_type, :with_waived_thresholds, ccms_code: "DA003", client_involvement_type: "A"),
          build(:proceeding_type, gross_income_upper_threshold: 8000, ccms_code: "SE013", client_involvement_type: "A"),
        ]
      end
      let(:assessment) { create :assessment, proceedings: [%w[DA002 A], %w[DA003 A], %w[SE013 A]] }
      let(:summary) do
        create :gross_income_summary,
               assessment:
      end
      let(:irregular_income_payments) { [build(:student_loan_payment, amount: 600), build(:unspecified_source_payment, amount: 16_615.40)] }
      let(:eligibilities) do
        proceeding_types.map do |proceeding_type|
          instance_double(Eligibility::GrossIncome,
                          proceeding_type:,
                          upper_threshold: proceeding_type.gross_income_upper_threshold,
                          lower_threshold: 0.0,
                          assessment_result: "eligible")
        end
      end

      let(:expected_hash) do
        {
          total_gross_income: 16_665.40,
          proceeding_types: [
            {
              ccms_code: "DA002",
              client_involvement_type: "A",
              upper_threshold: 999_999_999_999.0,
              lower_threshold: 0.0,
              result: "eligible",
            },
            {
              ccms_code: "DA003",
              client_involvement_type: "A",
              upper_threshold: 999_999_999_999.0,
              lower_threshold: 0.0,
              result: "eligible",
            },
            {
              ccms_code: "SE013",
              client_involvement_type: "A",
              upper_threshold: 8_000.0,
              lower_threshold: 0.0,
              result: "eligible",
            },
          ],
          combined_total_gross_income: 0.0,
        }
      end

      subject(:decorator) do
        described_class.new(eligibilities:,
                            combined_monthly_gross_income: 0,
                            total_gross_income: 16_665.40)
      end

      it "generates the expected hash" do
        expect(decorator.as_json).to eq expected_hash
      end
    end
  end
end
