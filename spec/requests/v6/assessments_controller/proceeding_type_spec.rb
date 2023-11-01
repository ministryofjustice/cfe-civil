require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, :calls_lfa, type: :request do
    let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
    let(:user_agent) { Faker::ProgrammingLanguage.name }
    let(:submission_date) { Date.new(2020, 11, 23) }
    let(:default_params) do
      {
        assessment: { submission_date:, level_of_help: },
        applicant: { date_of_birth: "2001-02-02",
                     receives_qualifying_benefit: false },
      }
    end

    around do |example|
      travel_to submission_date
      example.run
      travel_back
    end

    describe "POST /create" do
      before do
        post v6_assessments_path, params: params.to_json, headers:
      end

      context "with an invalid proceeding type" do
        let(:params) { default_params.merge(proceeding_types: [{ ccms_code: "ZZ", client_involvement_type: "A" }]) }
        let(:level_of_help) { "certificated" }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          codes = CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES.join(", ")
          expect(parsed_response[:errors])
            .to include(/The property '#\/proceeding_types\/0\/ccms_code' value "ZZ" did not match one of the following values: #{codes} in schema/)
        end
      end

      context "with empty proceeding types array" do
        let(:params) { default_params.merge(proceeding_types: []) }
        let(:level_of_help) { "certificated" }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response[:errors])
            .to include(/The property '#\/proceeding_types' did not contain a minimum number of items 1 in schema/)
        end
      end

      context "with missing proceeding_types" do
        let(:params) { default_params }

        context "certificated work" do
          let(:level_of_help) { "certificated" }

          it "doesnt error" do
            expect(response).to have_http_status(:ok)
          end
        end

        context "controlled work" do
          let(:level_of_help) { "controlled" }

          it "doesnt error" do
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
