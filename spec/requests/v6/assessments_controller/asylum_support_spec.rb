require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:current_date) { Date.new(2022, 6, 6).to_s }
    let(:submission_date_params) { { submission_date: current_date } }

    describe "POST /create" do
      context "receives_asylum_support" do
        let(:params) do
          {
            assessment: submission_date_params,
            applicant: {
              date_of_birth: "2001-02-02",
              has_partner_opponent: true,
              receives_qualifying_benefit: false,
              receives_asylum_support: true,
            },
            proceeding_types: [
              { ccms_code: "IA031", client_involvement_type: "A" },
            ],
          }
        end
        let(:overall_result) { parsed_response.dig(:result_summary, :overall_result, :result).to_sym }
        let(:gross_result) { parsed_response.dig(:result_summary, :gross_income, :proceeding_types).first.fetch(:result).to_sym }
        let(:disposable_result) { parsed_response.dig(:result_summary, :disposable_income, :proceeding_types).first.fetch(:result).to_sym }
        let(:capital_result) { parsed_response.dig(:result_summary, :capital, :proceeding_types).first.fetch(:result).to_sym }

        before do
          post v6_assessments_path, params: params.to_json, headers:
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "returns eligible and not calculated for all sections" do
          expect([overall_result, gross_result, disposable_result, capital_result]).to eq(%i[eligible not_calculated not_calculated not_calculated])
        end
      end
    end
  end
end
