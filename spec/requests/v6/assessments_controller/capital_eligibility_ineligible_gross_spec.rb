require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:current_date) { Date.new(2024, 3, 6) }
    let(:month1) { current_date.beginning_of_month - 3.months }
    let(:month2) { current_date.beginning_of_month - 2.months }
    let(:month3) { current_date.beginning_of_month - 1.month }

    around do |example|
      travel_to current_date
      example.run
      travel_back
    end

    def cash_transactions(amount)
      [month2, month3, month1].map do |p|
        {
          date: p.strftime("%F"),
          amount:,
          client_id: SecureRandom.uuid,
        }
      end
    end

    context "ineligible for all 3 sections" do
      let(:cash_transactions_params) do
        {
          income: [
            { category: "friends_or_family", payments: cash_transactions(4250.0) },
          ],
        }
      end
      let(:params) do
        {
          assessment: {
            submission_date: current_date.to_s,
            level_of_help: "controlled",
          },
          applicant: {
            date_of_birth: (current_date - 25.years).to_s,
            has_partner_opponent: false,
            receives_qualifying_benefit: false,
          },
          proceeding_types: [
            { ccms_code: "SE013", client_involvement_type: "A" },
          ],
          cash_transactions: cash_transactions_params,
          properties: {
            additional_properties: [
              {
                value: 500_000,
                outstanding_mortgage: 0,
                "percentage_owned": 100,
                "shared_with_housing_assoc": false,
              },
            ],
          },
        }
      end
      let(:overall_result) { parsed_response.dig(:result_summary, :overall_result, :result).to_sym }
      let(:gross_result) { parsed_response.dig(:result_summary, :gross_income, :proceeding_types).first.fetch(:result).to_sym }
      let(:disposable_result) { parsed_response.dig(:result_summary, :disposable_income, :proceeding_types).first.fetch(:result).to_sym }
      let(:capital_result) { parsed_response.dig(:result_summary, :capital, :proceeding_types).first.fetch(:result).to_sym }

      before do
        post v6_assessments_path, params: params.to_json, headers:
      end

      it "has no errors" do
        expect(parsed_response[:errors]).to eq(nil)
      end

      it "returns everything ineligible" do
        expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[ineligible ineligible ineligible ineligible])
      end
    end
  end
end
