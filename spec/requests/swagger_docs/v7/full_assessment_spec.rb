require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, type: :request, swagger_doc: "v7/swagger.yaml" do
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
                  required: %i[assessment applicant proceeding_types],
                  additionalProperties: false,
                  properties: {
                    assessment: { "$ref" => components[:assessment] },
                    applicant: { "$ref" => components[:applicant] },
                    proceeding_types: { "$ref" => components[:proceeding_types] },
                    capitals: { "$ref" => components[:capitals] },
                    cash_transactions: { "$ref" => components[:cash_transactions] },
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: { "$ref" => components[:dependant] },
                    },
                    employment_income: { "$ref" => components[:employments] },
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
                        main_home: { "$ref" => components[:property] },
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant",
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
                      description: "One or more employment details",
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
                      description: "Full information about an applicant's partner",
                      example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
                      additionalProperties: false,
                      properties: {
                        partner: {
                          type: :object,
                          description: "The partner of the applicant",
                          required: %i[date_of_birth],
                          additionalProperties: false,
                          properties: {
                            date_of_birth: {
                              type: :string,
                              format: :date,
                              example: "1992-07-22",
                              description: "Applicant's partner's date of birth",
                            },
                            employed: {
                              type: :boolean,
                              description: "Deprecated - employment is determined by presence of gross employment income",
                              deprecated: true,
                            },
                          },
                        },
                        cash_transactions: { "$ref" => components[:cash_transactions] },
                        outgoings: { type: :array },
                        irregular_incomes: { "$ref" => components[:irregular_income_payments] },
                        employments: { "$ref" => components[:employments] },
                        employment_details: {
                          type: :array,
                          description: "One or more employment details for partner",
                          items: { "$ref" => components[:employment_details] },
                        },
                        self_employment_details: {
                          type: :array,
                          description: "One or more self employment details for partner",
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
                          description: "One or more additional properties owned by the applicant's partner",
                          items: { "$ref" => components[:property] },
                        },
                        capitals: { "$ref" => components[:capitals] },
                        vehicles: {
                          type: :array,
                          description: "One or more vehicles' details",
                          items: { "$ref" => components[:vehicle] },
                        },
                        dependants: {
                          type: :array,
                          description: "One or more dependants details",
                          items: { "$ref" => components[:dependant] },
                        },
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
                         result: {
                           type: :string,
                           enum: %w[eligible ineligible contribution_required],
                         },
                         income_contribution: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of income contribution required (only valid if result is contribution_required)",
                         },
                         capital_contribution: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of capital contribution required (only valid if result is contribution_required)",
                         },
                         proceeding_types: {
                           type: :array,
                           minItems: 1,
                           items: { "$ref" => components[:proceeding_type_result] },
                         },
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
                         proceeding_types: {
                           type: :array,
                           minItems: 1,
                           items: { "$ref" => components[:proceeding_type_result] },
                         },
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
                     disposable_income: { "$ref": components[:applicant_disposable_income] },
                     partner_disposable_income: { "$ref": components[:disposable_income] },
                     capital: { "$ref": components[:applicant_capital_result] },
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
                     gross_income: {
                       type: :object,
                       additionalProperties: false,
                       required: %i[employment_income irregular_income state_benefits other_income],
                       properties: {
                         employment_income: {
                           type: :array,
                           items: {
                             type: :object,
                             additionalProperties: false,
                             required: %i[name payments],
                             properties: {
                               name: { type: :string },
                               payments: { type: :array },
                             },
                           },
                         },
                         irregular_income: {
                           type: :object,
                           additionalProperties: false,
                           required: %i[monthly_equivalents],
                           properties: {
                             monthly_equivalents: {
                               type: :object,
                               additionalProperties: false,
                               required: %i[student_loan unspecified_source],
                               properties: {
                                 student_loan: { type: :number },
                                 unspecified_source: { type: :number },
                               },
                             },
                           },
                         },
                         state_benefits: { "$ref": components[:state_benefits_result] },
                         other_income: { "$ref": components[:other_income_result] },
                         self_employments: {
                           type: :array,
                           items: {
                             type: :object,
                             additionalProperties: false,
                             required: %i[monthly_income],
                             properties: {
                               client_reference: {
                                 type: :string,
                                 description: "client reference from request",
                               },
                               monthly_income: {
                                 type: :object,
                                 description: "Monthly versions of input data",
                                 additionalProperties: false,
                                 required: %i[gross tax national_insurance benefits_in_kind],
                                 properties: {
                                   gross: {
                                     type: :number,
                                     format: :decimal,
                                     minimum: 0,
                                     description: "A positive number representing a gross income",
                                     example: "2050.20",
                                   },
                                   tax: {
                                     type: :number,
                                     format: :decimal,
                                     maximum: 0,
                                     description: "A negative number representing a tax deduction",
                                     example: "-250.20",
                                   },
                                   national_insurance: {
                                     type: :number,
                                     format: :decimal,
                                     maximum: 0,
                                     description: "A negative number representing a National Insurance deduction",
                                     example: "-150.20",
                                   },
                                   benefits_in_kind: {
                                     type: :number,
                                     minimum: 0,
                                     format: :decimal,
                                     description: "A positive number representing a benefit in kind payment",
                                     example: "100.00",
                                   },
                                 },
                               },
                             },
                           },
                         },
                       },
                     },
                     disposable_income: { "$ref": components[:disposable_income_result] },
                     capital: {
                       type: :object,
                       additionalProperties: false,
                       properties: {
                         capital_items: {
                           type: :object,
                           additionalProperties: false,
                           required: %i[liquid non_liquid vehicles properties],
                           properties: {
                             liquid: {
                               type: :array,
                               items: { "$ref": components[:non_property_asset] },
                             },
                             non_liquid: {
                               type: :array,
                               items: { "$ref": components[:non_property_asset] },
                             },
                             vehicles: {
                               type: :array,
                               items: { "$ref": components[:non_property_asset] },
                             },
                             properties: {
                               type: :object,
                               additionalProperties: false,
                               properties: {
                                 main_home: {
                                   "$ref" => components[:property_result],
                                 },
                                 additional_properties: {
                                   type: :array,
                                   items: {
                                     "$ref" => components[:property_result],
                                   },
                                 },
                               },
                             },
                           },
                         },
                       },
                     },
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
            applicant: { date_of_birth: "2001-02-02", has_partner_opponent: false, receives_qualifying_benefit: false, employed: false },
            proceeding_types: [{ ccms_code: "SE013", client_involvement_type: "A" }],
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
          }
        end

        run_test!
      end
    end
  end
end
