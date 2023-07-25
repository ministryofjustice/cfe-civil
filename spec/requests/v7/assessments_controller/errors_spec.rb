require "rails_helper"

module V7
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
      let(:date_of_birth) { "1992-07-22" }
      let(:client_id) { "347b707b-d795-47c2-8b39-ccf022eae33b" }
      let(:user_agent) { Faker::ProgrammingLanguage.name }
      let(:current_date) { Date.new(2022, 6, 6) }
      let(:default_params) do
        {
          assessment: { submission_date: current_date.to_s },
          applicant: { date_of_birth: "2001-02-02",
                       receives_qualifying_benefit: false },
          proceeding_types: [{ ccms_code: "DA001" }],
        }
      end

      before do
        post v7_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "with default params" do
        let(:params) { {} }

        it "returns success" do
          expect(response).to be_successful
        end
      end

      context "with old proceeding types" do
        let(:params) { { proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }] } }

        it "complains about client involvement type" do
          expect(parsed_response[:errors]).to include(%r{The property '#/proceeding_types/0' contains additional properties \["client_involvement_type})
        end
      end

      context "with old applicant" do
        let(:params) do
          {
            applicant: { date_of_birth: "2001-02-02",
                         has_partner_opponent: false,
                         receives_qualifying_benefit: false,
                         employed: true },
          }
        end

        it "complains about applicant" do
          expect(parsed_response[:errors]).to include(%r{The property '#/applicant' contains additional properties \["has_partner_opponent})
        end
      end

      context "with old employment payments" do
        let(:params) do
          { employment_income: [
            {
              name: "Job 1",
              client_id: SecureRandom.uuid,
              payments: [
                {
                  client_id: SecureRandom.uuid,
                  gross: 846.00,
                  benefits_in_kind: 16.60,
                  tax: -104.10,
                  national_insurance: -18.66,
                  net_employment_income: 765.34,
                  date: "2022-01-01",
                },
              ],
            },
          ] }
        end

        it "complains about employment net_income" do
          expect(parsed_response[:errors]).to include(%r{The property '#/employment_income/0/payments/0' contains additional properties \["net_employment_income})
        end
      end

      context "with old partner attribute" do
        let(:params) do
          { partner: { partner: { employed: true, date_of_birth: } } }
        end

        it "returns error JSON for '#/partner/partner'" do
          expect(parsed_response[:errors]).to include(%r{The property '#/partner/partner' contains additional properties})
        end
      end
    end
  end
end
