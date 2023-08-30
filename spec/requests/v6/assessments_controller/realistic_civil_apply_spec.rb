require "rails_helper"

# Purpose of this spec is to test the real submission by the "Civil Apply" covering as many fields filled in as possible
# Civil apply never send data for employment_details, self_employment_details and partner

module V6
  RSpec.describe AssessmentsController, :calls_bank_holiday, type: :request do
    describe "POST /create" do
      before do
        create :state_benefit_type, label: "personal_independent_payments"
        post v6_assessments_path, params: params.to_json, headers:
      end

      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'HTTP_USER_AGENT': "CivilApply/1.0 production" } }
      let(:params) do
        {
          "assessment": {
            "level_of_help": "certificated",
            "submission_date": "2023-08-15",
            "client_reference_id": "3000-01-01",
          },
          "applicant": {
            "employed": true,
            "date_of_birth": "1982-08-16",
            "involvement_type": "applicant",
            "has_partner_opponent": false,
            "receives_qualifying_benefit": true,
          },
          "proceeding_types": [
            {
              "ccms_code": "DA004",
              "client_involvement_type": "A",
            },
          ],
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
          "cash_transactions": {
            "income": [
              {
                "category": "friends_or_family",
                "payments": [
                  {
                    "date": "2023-04-01",
                    "amount": 250.0,
                    "client_id": "3000-01-01",
                  },
                  {
                    "date": "2023-05-01",
                    "amount": 250.0,
                    "client_id": "3000-01-01",
                  },
                  {
                    "date": "2023-06-01",
                    "amount": 250.0,
                    "client_id": "3000-01-01",
                  },
                ],
              },
            ],
            "outgoings": [
              {
                "category": "rent_or_mortgage",
                "payments": [
                  {
                    "date": "2023-04-01",
                    "amount": 200.0,
                    "client_id": "3000-01-01",
                  },
                  {
                    "date": "2023-05-01",
                    "amount": 200.0,
                    "client_id": "3000-01-01",
                  },
                  {
                    "date": "2023-06-01",
                    "amount": 160.0,
                    "client_id": "3000-01-01",
                  },
                ],
              },
            ],
          },
          "dependants": [
            {
              "assets_value": 0.0,
              "relationship": "child_relative",
              "date_of_birth": "2020-08-14",
              "monthly_income": 0.0,
              "in_full_time_education": true,
            },
            {
              "assets_value": 0.0,
              "relationship": "child_relative",
              "date_of_birth": "2021-08-14",
              "monthly_income": 0.0,
              "in_full_time_education": false,
            },
          ],
          "employment_income": [
            {
              "name": "Job 1",
              "payments": [
                {
                  "tax": -159.6,
                  "date": "2023-02-20",
                  "gross": 1868.25,
                  "client_id": "3000-01-01",
                  "benefits_in_kind": 0.0,
                  "national_insurance": -98.43,
                  "net_employment_income": 1610.22,
                },
              ],
              "client_id": "3000-01-01",
            },
          ],
          "irregular_incomes": {
            "payments": [
              {
                "amount": 8000.0,
                "frequency": "annual",
                "income_type": "student_loan",
              },
            ],
          },
          "other_incomes": [
            {
              "source": "Maintenance in",
              "payments": [
                {
                  "date": "2023-04-26",
                  "amount": 167.0,
                  "client_id": "3000-01-01",
                },
              ],
            },
          ],
          "outgoings": [
            {
              "name": "rent_or_mortgage",
              "payments": [
                {
                  "amount": 563.08,
                  "client_id": "3000-01-01",
                  "payment_date": "2023-05-02",
                  "housing_cost_type": "mortgage",
                },
              ],
            },
            {
              "name": "maintenance_out",
              "payments": [
                {
                  "amount": 30.0,
                  "client_id": "3000-01-01",
                  "payment_date": "2023-05-15",
                },
              ],
            },
          ],
          "properties": {
            "main_home": {
              "value": 720_000.0,
              "percentage_owned": 50.0,
              "outstanding_mortgage": 325_000.0,
              "shared_with_housing_assoc": false,
            },
            "additional_properties": [
              {
                "value": 435_000.0,
                "percentage_owned": 100.0,
                "outstanding_mortgage": 435_000.0,
                "shared_with_housing_assoc": false,
              },
            ],
          },
          "regular_transactions": [
            {
              "amount": 90.0,
              "category": "benefits",
              "frequency": "four_weekly",
              "operation": "credit",
            },
          ],
          "state_benefits": [
            {
              "name": "personal_independent_payments",
              "payments": [
                {
                  "date": "2023-05-26",
                  "amount": 691.0,
                  "client_id": "3000-01-01",
                },
                {
                  "date": "2023-06-26",
                  "amount": 691.0,
                  "client_id": "3000-01-01",
                },
                {
                  "date": "2023-07-24",
                  "amount": 691.0,
                  "client_id": "3000-01-01",
                },
              ],
            },
          ],
          "vehicles": [
            {
              "value": 3500.0,
              "in_regular_use": true,
              "date_of_purchase": "2021-07-19",
              "loan_amount_outstanding": 1500.0,
            },
          ],
          "explicit_remarks": [
            {
              "details": %w[
                criminal_injuries_compensation_scheme
              ],
              "category": "policy_disregards",
            },
          ],
        }
      end

      context "successful submission" do
        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
