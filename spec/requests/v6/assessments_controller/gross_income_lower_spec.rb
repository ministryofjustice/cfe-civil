require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:current_date) { Date.new(2525, 6, 6) }

    around do |example|
      travel_to current_date
      example.run
      travel_back
    end

    describe "post-MTR gross income lower threshold for controlled work" do
      context "no income controlled work with lots of capital" do
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
            properties: {
              additional_properties: [
                {
                  value: 50_000,
                  outstanding_mortgage: 70.25,
                  "percentage_owned": 99.99,
                  "shared_with_housing_assoc": true,
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
          expect(parsed_response[:errors]).to be_nil
        end

        it "returns eligible even though capital is ineligible" do
          expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[eligible eligible eligible eligible])
        end
      end
    end
  end
end
