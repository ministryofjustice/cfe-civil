require "rails_helper"

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': user_agent } }
      let(:employed) { false }
      let(:user_agent) { Faker::ProgrammingLanguage.name }
      let(:current_date) { Date.new(2022, 6, 6) }
      let(:submission_date) { current_date.to_s }
      let(:dob) { "2001-02-02" }
      let(:client_reference_id) { "3000-01-01" }
      let(:default_params) do
        {
          "capitals": {
            "bank_accounts": [
              {
                "value": "29.78",
                "description": "Current accounts",
              },
            ],
            "non_liquid_capital": [],
          },
          "vehicles": [
            {
              "value": 750.0,
              "in_regular_use": true,
              "date_of_purchase": "2021-08-24",
              "loan_amount_outstanding": 0.0,
            },
          ],
          "applicant": {
            "employed": nil,
            "date_of_birth": dob,
            "involvement_type": "applicant",
            "has_partner_opponent": false,
            "receives_qualifying_benefit": true,
          },
          "assessment": {
            "level_of_help": "certificated",
            "submission_date": submission_date,
            "client_reference_id": client_reference_id,
          },
          "properties": {
            "main_home": {
              "value": 0.0,
              "percentage_owned": 0.0,
              "outstanding_mortgage": 0.0,
              "shared_with_housing_assoc": false,
            },
            "additional_properties": [
              {
                "value": 0.0,
                "percentage_owned": 0.0,
                "outstanding_mortgage": 0.0,
                "shared_with_housing_assoc": false,
              },
            ],
          },
          "explicit_remarks": [
            {
              "details": [],
              "category": "policy_disregards",
            },
          ],
          "proceeding_types": [
            {
              "ccms_code": "DA004",
              "client_involvement_type": "A",
            },
          ],
        }
      end

      let(:params) { {} }

      before do
        post v6_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "successful submission" do
        context "with capitals.bank_accounts[].value as string" do
          let(:params) do
            {
              "capitals": {
                "bank_accounts": [
                  {
                    "value": "14.68",
                    "description": "Current accounts",
                  },
                ],
                "non_liquid_capital": [],
              },
            }
          end

          it "returns http success" do
            expect(response).to have_http_status(:success)
          end
        end

        context "with capitals.bank_accounts[].value as decimal" do
          let(:params) do
            {
              "capitals": {
                "bank_accounts": [
                  {
                    "value": 14.68,
                    "description": "Current accounts",
                  },
                ],
                "non_liquid_capital": [],
              },
            }
          end

          it "returns http success" do
            expect(response).to have_http_status(:success)
          end
        end

        context "with vehicles[].value as string" do
          let(:params) do
            {
              "vehicles": [
                {
                  "value": "750.0",
                  "in_regular_use": true,
                  "date_of_purchase": "2021-08-24",
                  "loan_amount_outstanding": 0.0,
                },
              ],
            }
          end

          it "returns http success" do
            expect(response).to have_http_status(:success)
          end
        end

        context "with vehicles[].value as decimal" do
          let(:params) do
            {
              "vehicles": [
                {
                  "value": 750.0,
                  "in_regular_use": true,
                  "date_of_purchase": "2021-08-24",
                  "loan_amount_outstanding": 0.0,
                },
              ],
            }
          end

          it "returns http success" do
            expect(response).to have_http_status(:success)
          end
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
