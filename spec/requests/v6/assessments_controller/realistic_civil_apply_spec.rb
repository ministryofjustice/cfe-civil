require "rails_helper"

##### Purpose of this spec is to test the real submission by the "Civil Apply" covering as many fields filled in as possible #####

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': "CivilApply/1.0 production" } }
      let(:default_params) do
        {
          "capitals": {
            "bank_accounts": [
              {
                "value": "520.8",
                "description": "Current accounts",
              },
            ],
            "non_liquid_capital": [
              {
                "value": "1000.0",
                "description": "Any valuable items worth more than £500",
              },
            ],
          },
          "vehicles": [
            {
              "value": 4977.7,
              "in_regular_use": true,
              "date_of_purchase": "2019-08-15",
              "loan_amount_outstanding": 3234.02,
              "subject_matter_of_dispute": false,
            },
          ],
          "applicant": {
            "employed": true,
            "date_of_birth": "1982-08-16",
            "involvement_type": "applicant",
            "has_partner_opponent": false,
            "receives_qualifying_benefit": true,
          },
          "assessment": {
            "level_of_help": "certificated",
            "submission_date": "2023-08-15",
            "client_reference_id": "3000-01-01",
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
              "details": %w[
                criminal_injuries_compensation_scheme
              ],
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
        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
