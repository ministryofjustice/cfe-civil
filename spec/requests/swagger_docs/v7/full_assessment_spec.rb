require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, :calls_lfa, type: :request, swagger_doc: "v7/swagger.yaml" do
  path "/v7/assessments" do
    post("create") do
      tags "Perform assessment with single call"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Performs a complete assessment
      DESCRIPTION

      components = SwaggerDocs::SCHEMA_COMPONENTS

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[assessment applicant],
                  additionalProperties: false,
                  properties: {
                    assessment: { "$ref" => components[:assessment] },
                    applicant: { "$ref" => components[:v7_applicant] },
                    proceeding_types: { "$ref" => components[:proceeding_types] },
                    capitals: { "$ref" => components[:capitals] },
                    cash_transactions: { "$ref" => components[:cash_transactions] },
                    dependants: { "$ref" => components[:v7_dependants] },
                    employment_income: { "$ref" => components[:v7_employments] },
                    irregular_incomes: {
                      type: :object,
                      description: "A set of irregular income payments",
                      required: %i[payments],
                      additionalProperties: false,
                      example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                      properties: {
                        payments: { "$ref" => components[:irregular_income_payments] },
                      },
                    },
                    other_incomes: { "$ref" => components[:other_incomes] },
                    outgoings: { "$ref" => components[:outgoings_list] },
                    properties: {
                      type: :object,
                      required: %i[],
                      description: "A main home and additional properties",
                      additionalProperties: false,
                      properties: {
                        main_home: { "$ref" => components[:main_home] },
                        additional_properties: {
                          type: :array,
                          description: "Additional properties owned by the applicant - i.e. not including the main home",
                          items: { "$ref" => components[:property] },
                        },
                      },
                    },
                    regular_transactions: {
                      type: :array,
                      description: "Zero or more regular transactions",
                      items: { "$ref" => components[:regular_transaction] },
                    },
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits received by the applicant and categorized by name",
                      items: { "$ref" => components[:state_benefit] },
                    },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => components[:vehicle] },
                    },
                    employment_details: {
                      type: :array,
                      description: "Employments, with pay info supplied in the 'how much, how often' pattern",
                      items: { "$ref" => components[:employment_details] },
                    },
                    self_employment_details: {
                      type: :array,
                      description: "One or more self employment details",
                      items: { "$ref" => components[:self_employment] },
                    },
                    partner: {
                      type: :object,
                      required: %i[partner],
                      description: "Partner of the applicant's financial and personal info. Definition of 'partner' that should included in the means test is described in the Lord Chancellor's guidance - certificated: '3.1 Individual and partner', controlled: '4.2 Aggregation of Means'.",
                      example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
                      additionalProperties: false,
                      properties: {
                        partner: {
                          type: :object,
                          description: "Partner's personal info",
                          required: %i[date_of_birth],
                          additionalProperties: false,
                          properties: {
                            date_of_birth: {
                              type: :string,
                              format: :date,
                              example: "1992-07-22",
                              description: "Partner's date of birth",
                            },
                          },
                        },
                        cash_transactions: { "$ref" => components[:cash_transactions] },
                        outgoings: { type: :array },
                        irregular_incomes: { "$ref" => components[:irregular_income_payments] },
                        employments: { "$ref" => components[:v7_employments] },
                        employment_details: {
                          type: :array,
                          description: "Employments, with pay info supplied in the 'how much, how often' pattern, for partner",
                          items: { "$ref" => components[:employment_details] },
                        },
                        self_employment_details: {
                          type: :array,
                          description: "Self employments, with pay info supplied in the 'how much, how often' pattern, for partner",
                          items: { "$ref" => components[:self_employment] },
                        },
                        regular_transactions: {
                          type: :array,
                          description: "Zero or more regular transactions",
                          items: { "$ref" => components[:regular_transaction] },
                        },
                        state_benefits: {
                          type: :array,
                          description: "One or more state benefits received by the applicant's partner and categorized by name",
                          items: { "$ref" => components[:state_benefit] },
                        },
                        additional_properties: {
                          type: :array,
                          description: "Additional properties owned by the partner - i.e. excluding those already listed for the applicant",
                          items: { "$ref" => components[:property] },
                        },
                        capitals: { "$ref" => components[:capitals] },
                        vehicles: {
                          type: :array,
                          description: "One or more vehicles' details",
                          items: { "$ref" => components[:vehicle] },
                        },
                        dependants: { "$ref" => components[:v7_dependants] },
                      },
                    },
                    explicit_remarks: { "$ref" => components[:explicit_remarks] },
                  },
                }

      response(200, "successful") do
        schema type: :object,
               required: %i[timestamp result_summary assessment version success],
               additionalProperties: false,
               properties: {
                 result_summary: {
                   type: :object,
                   additionalProperties: false,
                   required: %i[overall_result gross_income disposable_income capital],
                   properties: {
                     overall_result: {
                       type: :object,
                       additionalProperties: false,
                       required: %i[result capital_contribution income_contribution proceeding_types],
                       properties: {
                         result: { "$ref" => components[:overall_result] },
                         income_contribution: { "$ref" => components[:income_contribution] },
                         capital_contribution: { "$ref" => components[:capital_contribution] },
                         proceeding_types: { "$ref" => components[:proceeding_type_results] },
                       },
                     },
                     gross_income: {
                       type: :object,
                       additionalProperties: false,
                       description: "gross_income calculation for partner, with some combined totals where appropriate",
                       required: %i[total_gross_income combined_total_gross_income proceeding_types],
                       properties: {
                         total_gross_income: {
                           type: :number,
                           format: :decimal,
                           description: "Calculated monthly total gross income for applicant",
                         },
                         combined_total_gross_income: {
                           type: :number,
                           format: :decimal,
                           description: "Calculated monthly total gross income for applicant and partner",
                         },
                         proceeding_types: { "$ref" => components[:proceeding_type_results] },
                       },
                     },
                     partner_gross_income: {
                       type: :object,
                       additionalProperties: false,
                       required: %i[total_gross_income],
                       properties: {
                         total_gross_income: {
                           type: :number,
                           format: :decimal,
                           description: "Calculated monthly total gross income for partner",
                         },
                       },
                     },
                     disposable_income: { "$ref": components[:v7_applicant_disposable_income] },
                     partner_disposable_income: { "$ref": components[:v7_disposable_income] },
                     capital: { "$ref": components[:v7_applicant_capital_result] },
                     partner_capital: { "$ref": components[:capital_result] },
                   },
                 },
                 assessment: {
                   type: :object,
                   additionalProperties: false,
                   properties: {
                     id: { type: :string },
                     client_reference_id: { type: :string, nullable: true, example: "ref-11-22" },
                     submission_date: { type: :string, format: :date, example: "2022-07-22" },
                     level_of_help: {
                       type: :string,
                       enum: Assessment::LEVELS_OF_HELP,
                       example: Assessment::LEVELS_OF_HELP.first,
                       description: "The level of representation required by the client",
                     },
                     applicant: { "$ref": components[:applicant_result] },
                     gross_income: { "$ref": components[:gross_income_result] },
                     disposable_income: { "$ref": components[:disposable_income_result] },
                     capital: { "$ref": components[:assessment_capital_result] },
                     partner_gross_income: { "$ref": components[:gross_income_result] },
                     partner_disposable_income: { "$ref": components[:disposable_income_result] },
                     partner_capital: { "$ref": components[:assessment_capital_result] },
                     remarks: { "$ref" => components[:remarks] },
                   },
                 },
                 version: {
                   type: :string,
                   enum: %w[7],
                   description: "Version of the API used in the request",
                 },
                 success: {
                   type: :boolean,
                   description: "Always true when HTTP 200 returned, false otherwise",
                 },
                 timestamp: {
                   type: :string,
                 },
               }

        let(:params) do
          {
            assessment: { submission_date: "2022-06-06" },
            applicant: { date_of_birth: "2001-02-02", receives_qualifying_benefit: false },
            proceeding_types: [{ ccms_code: "SE013", client_involvement_type: "W" }],
            outgoings: [
              { name: "child_care", payments: [{ amount: 10.00, client_id: "blah", payment_date: "2022-05-06" }] },
              { name: "rent_or_mortgage", payments: [{ amount: 10.00, client_id: "blah", payment_date: "2022-05-06", housing_cost_type: "rent" }] },
            ],
            cash_transactions: {
              outgoings: [
                { category: "child_care",
                  payments: [{ amount: 10.00, client_id: SecureRandom.uuid, date: "2022-03-01" },
                             { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-04-01" },
                             { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-05-01" }] },
                { category: "rent_or_mortgage",
                  payments: [
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-03-01" },
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-04-01" },
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-05-01" },
                  ] },
              ],
              income: [],
            },
            employment_details: [
              income: {
                frequency: "monthly",
                gross: 24,
                tax: -2,
                benefits_in_kind: 36,
                national_insurance: -5,
                receiving_only_statutory_sick_or_maternity_pay: false,
              },
            ],
            partner: {
              partner: {
                date_of_birth: "1992-07-22",
              },
              employment_details: [
                income: {
                  frequency: "monthly",
                  gross: 24,
                  tax: -2,
                  benefits_in_kind: 36,
                  national_insurance: -5,
                  receiving_only_statutory_sick_or_maternity_pay: false,
                },
              ],
            },
          }
        end

        run_test!
      end
    end
  end
end
