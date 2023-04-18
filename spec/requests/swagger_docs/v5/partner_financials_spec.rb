require "swagger_helper"

RSpec.describe "partner_financials", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/partner_financials" do
    post("create ") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description << "Adds details of an applicant's partner."

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[partner],
                  description: "Full information about an applicant's partner",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
                  additionalProperties: false,
                  properties: {
                    partner: {
                      type: :object,
                      description: "The partner of the applicant",
                      required: %i[date_of_birth],
                      properties: {
                        date_of_birth: {
                          type: :string,
                          format: :date,
                          example: "1992-07-22",
                          description: "Applicant's partner's date of birth",
                        },
                        employed: {
                          type: :boolean,
                          example: true,
                          description: "Deprecated field - calculation uses presence of employment data",
                        },
                      },
                    },
                    irregular_incomes: { "$ref" => "#/components/schemas/IrregularIncomePayments" },
                    employments: { "$ref" => "#/components/schemas/Employments" },
                    outgoings: { "$ref" => "#/components/schemas/OutgoingsList" },
                    regular_transactions: {
                      type: :array,
                      description: "Zero or more regular transactions",
                      items: { "$ref" => "#/components/schemas/RegularTransaction" },
                    },
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits receved by the applicant's partner and categorized by name",
                      items: { "$ref" => "#/components/schemas/StateBenefit" },
                    },
                    additional_properties: {
                      type: :array,
                      description: "One or more additional properties owned by the applicant's partner",
                      items: { "$ref" => "#/components/schemas/Property" },
                    },
                    capitals: { "$ref" => "#/components/schemas/Capitals" },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => "#/components/schemas/Vehicle" },
                    },
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: { "$ref" => "#/components/schemas/Dependant" },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment).id }
        before do
          create(:state_benefit_type, label: "other")
        end

        let(:params) do
          {
            partner: {
              date_of_birth: "1992-07-22",
              employed: true,
            },
            irregular_incomes: [
              {
                income_type: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.first,
                frequency: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES.first,
                amount: 101.01,
              },
            ],
            employments: [
              {
                name: "A",
                client_id: "B",
                payments: [
                  {
                    client_id: "C",
                    date: "1992-07-22",
                    gross: 101.01,
                    benefits_in_kind: 0.0,
                    tax: 11,
                    national_insurance: 3.0,
                  },
                ],
              },
            ],
            regular_transactions: [
              {
                category: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES.first,
                operation: "credit",
                frequency: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.first,
                amount: 101.01,
              },
            ],
            state_benefits: [
              {
                name: "D",
                payments: [
                  {
                    client_id: "E",
                    date: "1992-07-22",
                    amount: 101.01,
                    flags: {
                      multi_benefit: false,
                    },
                  },
                ],
              },
            ],
            additional_properties: [
              {
                value: 500_000.01,
                outstanding_mortgage: 999.99,
                percentage_owned: 100,
                shared_with_housing_assoc: false,
                subject_matter_of_dispute: false,
              },
            ],
            capitals: {
              bank_accounts: [
                {
                  value: 1.01,
                  description: "F",
                  subject_matter_of_dispute: false,
                },
              ],
              non_liquid_capital: [
                {
                  value: 1.01,
                  description: "G",
                  subject_matter_of_dispute: false,
                },
              ],
            },
            vehicles: [
              {
                value: 5_000,
                loan_amount_outstanding: 1_000,
                date_of_purchase: "2017-01-23",
                in_regular_use: true,
                subject_matter_of_dispute: false,
              },
            ],
            dependants: [
              {
                date_of_birth: "1983-08-08",
                in_full_time_education: false,
                relationship: "adult_relative",
                monthly_income: 4448.63,
                assets_value: 0.0,
              },
            ],
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end

      response(422, "Unprocessable Entity") do\
        let(:assessment_id) { create(:assessment).id }

        let(:params) { { partner: {} } }

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/partner' did not contain a required property of 'date_of_birth' in schema/)
        end
      end
    end
  end
end
