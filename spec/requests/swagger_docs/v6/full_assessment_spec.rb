require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, type: :request, swagger_doc: "v6/swagger.yaml" do
  path "/v6/assessments" do
    let(:state_benefit_type1) { create :state_benefit_type, exclude_from_gross_income: true }

    post("create") do
      tags "Perform assessment with single call"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Performs a complete assessment
      DESCRIPTION

      prisoner_levy: {
        type: :number,
        format: :decimal,
        maximum: 0,
        description: "A negative number representing a Prisoner Levy deduction",
        example: "-20.00",
      },

      components = SwaggerDocs::SCHEMA_COMPONENTS

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[assessment applicant proceeding_types],
                  additionalProperties: false,
                  properties: {
                    assessment: { "$ref" => components[:assessment] },
                    applicant: { "$ref" => components[:v6_applicant] },
                    proceeding_types: { "$ref" => components[:v6_proceeding_types] },
                    capitals: { "$ref" => components[:capitals] },
                    cash_transactions: { "$ref" => components[:cash_transactions] },
                    dependants: { "$ref" => components[:v6_dependants] },
                    employment_income: { "$ref" => components[:v6_employments] },
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
                      description: "Benefits paid by the state to the applicant. One item per type of benefit",
                      items: { "$ref" => components[:state_benefit] },
                    },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => components[:vehicle] },
                    },
                    employment_details: {
                      type: :array,
                      description: "Employments, with pay info supplied in the 'how much, how often' pattern. (Compare with: 'employment_income')",
                      items: { "$ref" => components[:employment_details] },
                    },
                    self_employment_details: {
                      type: :array,
                      description: "Self employments, with pay info supplied in the 'how much, how often' pattern",
                      items: { "$ref" => components[:self_employment] },
                    },
                    partner: {
                      type: :object,
                      required: %i[partner],
                      additionalProperties: false,
                      description: "Partner of the applicant's financial and personal info. Definition of 'partner' that should included in the means test is described in the Lord Chancellor's guidance - certificated: '3.1 Individual and partner', controlled: '4.2 Aggregation of Means'.",
                      example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
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
                            employed: {
                              type: :boolean,
                              description: "Deprecated - employment is now determined by presence of gross employment income",
                              deprecated: true,
                            },
                          },
                        },
                        cash_transactions: { "$ref" => components[:cash_transactions] },
                        outgoings: { "$ref" => components[:outgoings_list] },
                        irregular_incomes: { "$ref" => components[:irregular_income_payments] },
                        employments: { "$ref" => components[:v6_employments] },
                        employment_details: {
                          type: :array,
                          description: "Employments, with pay info supplied in the 'how much, how often' pattern, for partner. (Compare with: 'employments')",
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
                        dependants: { "$ref" => components[:v6_dependants] },
                        other_incomes: { "$ref" => components[:other_incomes] },
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
                   required: %i[overall_result gross_income disposable_income capital],
                   additionalProperties: false,
                   properties: {
                     overall_result: {
                       type: :object,
                       required: %i[result capital_contribution income_contribution proceeding_types],
                       additionalProperties: false,
                       properties: {
                         result: { "$ref" => components[:overall_result] },
                         income_contribution: { "$ref" => components[:income_contribution] },
                         capital_contribution: { "$ref" => components[:capital_contribution] },
                         proceeding_types: { "$ref" => components[:v6_proceeding_type_results] },
                       },
                     },
                     gross_income: {
                       type: :object,
                       description: "gross_income calculation for partner, with some combined totals where appropriate",
                       required: %i[total_gross_income combined_total_gross_income proceeding_types],
                       additionalProperties: false,
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
                         proceeding_types: { "$ref" => components[:v6_proceeding_type_results] },
                       },
                     },
                     partner_gross_income: {
                       type: :object,
                       required: %i[total_gross_income],
                       additionalProperties: false,
                       properties: {
                         total_gross_income: {
                           type: :number,
                           format: :decimal,
                           description: "Calculated monthly total gross income for partner",
                         },
                       },
                     },
                     disposable_income: { "$ref": components[:v6_applicant_disposable_income] },
                     partner_disposable_income: { "$ref": components[:disposable_income] },
                     capital: { "$ref": components[:v6_applicant_capital_result] },
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
                       enum: Assessment.levels_of_help.keys,
                       example: Assessment.levels_of_help.keys.first,
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
                   enum: %w[6],
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
            applicant: { date_of_birth: "2001-02-02", has_partner_opponent: false, receives_qualifying_benefit: false, employed: false },
            dependants: [
              attributes_for(:dependant, relationship: "child_relative", in_full_time_education: true, date_of_birth: "2015-02-11").except(:income_amount, :income_frequency),
            ],
            employment_income: [
              {
                name: "Job 1",
                client_id: "employment-id-1",
                receiving_only_statutory_sick_or_maternity_pay: true,
                payments: [
                  {
                    client_id: "employment-1-payment-1",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                    prisoner_levy: -20.00,
                  },
                  {
                    client_id: "employment-1-payment-2",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                    prisoner_levy: -20.00,
                  },
                ],
              },
              {
                name: "Job 2",
                client_id: "employment-id-2",
                payments: [
                  {
                    client_id: "employment-2-payment-1",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: 14.10,
                    national_insurance: 3.66,
                    prisoner_levy: 20.00,
                  },
                  {
                    client_id: "employment-2-payment-2",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                    prisoner_levy: -20.00,
                  },
                  {
                    client_id: "employment-2-payment-3",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                    prisoner_levy: -20.00,
                  },
                ],
              },
            ],
            proceeding_types: [{ ccms_code: "SE013", client_involvement_type: "A" }],
            state_benefits: [
              {
                name: state_benefit_type1.label,
                payments: [
                  { date: "2022-11-01", amount: 33.44, client_id: SecureRandom.uuid, flags: { multi_benefit: true } },
                  { date: "2022-10-01", amount: 55.44, client_id: SecureRandom.uuid, flags: {} },
                  { date: "2022-09-01", amount: 77.44, client_id: SecureRandom.uuid, flags: {} },
                ],
              },
            ],
            other_incomes: [
              {
                source: "friends_or_family",
                payments: [
                  { date: "2022-11-01", amount: 25.00, client_id: SecureRandom.uuid },
                  { date: "2022-10-01", amount: 34.02, client_id: SecureRandom.uuid },
                  { date: "2022-09-01", amount: 76.00, client_id: SecureRandom.uuid },
                ],
              },
            ],
            outgoings: [
              {
                name: "child_care",
                payments: [
                  { payment_date: "2022-10-15", amount: 29.12, client_id: SecureRandom.uuid },
                  { payment_date: "2022-10-15", amount: 59.12, client_id: SecureRandom.uuid },
                ],
              },
              {
                name: "legal_aid",
                payments: [
                  { payment_date: "2022-10-15", amount: 19.87, client_id: SecureRandom.uuid },
                  { payment_date: "2022-11-15", amount: 89.87, client_id: SecureRandom.uuid },
                ],
              },
              {
                name: "maintenance_out",
                payments: [
                  { amount: 33.07, client_id: SecureRandom.uuid, payment_date: "2022-10-15" },
                  { amount: 53.07, client_id: SecureRandom.uuid, payment_date: "2022-11-15" },
                  { amount: 73.07, client_id: SecureRandom.uuid, payment_date: "2022-12-15" },
                ],
              },
              {
                name: "rent_or_mortgage",
                payments: [
                  { payment_date: "2022-11-15", amount: 51.49, housing_cost_type: "rent", client_id: SecureRandom.uuid },
                  { payment_date: "2022-10-15", amount: 76.49, housing_cost_type: "rent", client_id: SecureRandom.uuid },
                ],
              },
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
