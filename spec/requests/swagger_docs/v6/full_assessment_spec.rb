require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, type: :request, swagger_doc: "v6/swagger.yaml" do
  path "/v6/assessments" do
    post("create") do
      tags "Perform assessment with single call"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Performs a complete assessment
      DESCRIPTION

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[assessment applicant proceeding_types],
                  properties: {
                    assessment: { "$ref" => SCHEMA_COMPONENTS[:assessment] },
                    applicant: { "$ref" => SCHEMA_COMPONENTS[:applicant] },
                    proceeding_types: { "$ref" => SCHEMA_COMPONENTS[:proceeding_types] },
                    capitals: { "$ref" => SCHEMA_COMPONENTS[:capitals] },
                    cash_transactions: { "$ref" => SCHEMA_COMPONENTS[:cash_transactions] },
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: { "$ref" => SCHEMA_COMPONENTS[:dependant] },
                    },
                    employment_income: { "$ref" => SCHEMA_COMPONENTS[:employments] },
                    irregular_incomes: {
                      type: :object,
                      description: "A set of irregular income payments",
                      required: %i[payments],
                      additionalProperties: false,
                      example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                      properties: {
                        payments: { "$ref" => SCHEMA_COMPONENTS[:irregular_income_payments] },
                      },
                    },
                    other_incomes: { "$ref" => SCHEMA_COMPONENTS[:other_incomes] },
                    outgoings: { "$ref" => SCHEMA_COMPONENTS[:outgoings_list] },
                    properties: {
                      type: :object,
                      required: %i[],
                      description: "A main home and additional properties",
                      properties: {
                        main_home: { "$ref" => SCHEMA_COMPONENTS[:property] },
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant",
                          items: { "$ref" => SCHEMA_COMPONENTS[:property] },
                        },
                      },
                    },
                    regular_transactions: {
                      type: :array,
                      description: "Zero or more regular transactions",
                      items: { "$ref" => SCHEMA_COMPONENTS[:regular_transaction] },
                    },
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits received by the applicant and categorized by name",
                      items: { "$ref" => SCHEMA_COMPONENTS[:state_benefit] },
                    },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => SCHEMA_COMPONENTS[:vehicle] },
                    },
                    employment_details: {
                      type: :array,
                      description: "One or more employment details",
                      items: { "$ref" => SCHEMA_COMPONENTS[:employment_details] },
                    },
                    self_employment_details: {
                      type: :array,
                      description: "One or more self employment details",
                      items: { "$ref" => SCHEMA_COMPONENTS[:self_employment] },
                    },
                    partner: {
                      type: :object,
                      required: %i[partner],
                      description: "Full information about an applicant's partner",
                      example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
                      properties: {
                        partner: {
                          type: :object,
                          description: "The partner of the applicant",
                          required: %i[date_of_birth employed],
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
                              description: "Applicant's partner is employed",
                            },
                          },
                        },
                        outgoings: { type: :array },
                        irregular_incomes: { "$ref" => SCHEMA_COMPONENTS[:irregular_income_payments] },
                        employments: {
                          type: :array,
                          required: %i[name client_id payments],
                          description: "One or more employment income details",
                          items: {
                            type: :object,
                            description: "Employment income detail",
                            properties: {
                              name: {
                                type: :string,
                                description: "Identifying name for this employment - e.g. employer's name",
                              },
                              client_id: {
                                type: :string,
                                description: "Client supplied id to identify the employment",
                              },
                              payments: { "$ref" => SCHEMA_COMPONENTS[:employment_payment_list] },
                            },
                          },
                        },
                        employment_details: {
                          type: :array,
                          description: "One or more employment details for partner",
                          items: { "$ref" => SCHEMA_COMPONENTS[:employment_details] },
                        },
                        self_employment_details: {
                          type: :array,
                          description: "One or more self employment details for partner",
                          items: { "$ref" => SCHEMA_COMPONENTS[:self_employment] },
                        },
                        regular_transactions: {
                          type: :array,
                          description: "Zero or more regular transactions",
                          items: { "$ref" => SCHEMA_COMPONENTS[:regular_transaction] },
                        },
                        state_benefits: {
                          type: :array,
                          description: "One or more state benefits received by the applicant's partner and categorized by name",
                          items: { "$ref" => SCHEMA_COMPONENTS[:state_benefit] },
                        },
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant's partner",
                          items: { "$ref" => SCHEMA_COMPONENTS[:property] },
                        },
                        capitals: { "$ref" => SCHEMA_COMPONENTS[:capitals] },
                        vehicles: {
                          type: :array,
                          description: "One or more vehicles' details",
                          items: { "$ref" => SCHEMA_COMPONENTS[:vehicle] },
                        },
                        dependants: {
                          type: :array,
                          description: "One or more dependants details",
                          items: { "$ref" => SCHEMA_COMPONENTS[:dependant] },
                        },
                      },
                    },
                    explicit_remarks: { "$ref" => SCHEMA_COMPONENTS[:explicit_remarks] },
                  },
                }

      response(200, "successful") do
        schema type: :object,
               required: %i[timestamp result_summary assessment version success],
               properties: {
                 result_summary: {
                   type: :object,
                   required: %i[overall_result gross_income disposable_income capital],
                   properties: {
                     overall_result: {
                       type: :object,
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
                           items: { "$ref" => SCHEMA_COMPONENTS[:proceeding_type_result] },
                         },
                       },
                     },
                     gross_income: {
                       type: :object,
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
                           items: { "$ref" => SCHEMA_COMPONENTS[:proceeding_type_result] },
                         },
                       },
                     },
                     partner_gross_income: {
                       type: :object,
                       required: %i[total_gross_income],
                       properties: {
                         total_gross_income: {
                           type: :number,
                           format: :decimal,
                           description: "Calculated monthly total gross income for partner",
                         },
                       },
                     },
                     disposable_income: {
                       allOf: [
                         { "$ref": SCHEMA_COMPONENTS[:disposable_income] },
                         {
                           type: :object,
                           properties: {
                             partner_allowance: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Fixed allowance given if applicant has a partner for means assessment purposes",
                             },
                             combined_total_outgoings_and_allowances: {
                               type: :number,
                               format: :decimal,
                               description: "total_outgoings_and_allowances + partner total_outgoings_and_allowances",
                             },
                             combined_total_disposable_income: {
                               type: :number,
                               format: :decimal,
                               description: "total_disposable_income + partner total_disposable_income",
                             },
                             proceeding_types: {
                               type: :array,
                               minItems: 1,
                               items: { "$ref": SCHEMA_COMPONENTS[:proceeding_type_result] },
                             },
                           },
                         },
                       ],
                     },
                     partner_disposable_income: { "$ref": SCHEMA_COMPONENTS[:disposable_income] },
                     capital: {
                       allOf: [
                         { "$ref": SCHEMA_COMPONENTS[:capital_result] },
                         {
                           type: :object,
                           properties: {
                             proceeding_types: {
                               type: :array,
                               items: { "$ref": SCHEMA_COMPONENTS[:proceeding_type_result] },
                             },
                             pensioner_capital_disregard: {
                               type: :number,
                               format: :decimal,
                               description: "Cap on pensioner capital disregard for this assessment (based on disposable_income)",
                               minimum: 0.0,
                             },
                             pensioner_disregard_applied: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Amount of pensioner capital disregard applied to this assessment",
                             },
                             total_capital_with_smod: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Total of all capital but with subject matter of dispute deduction applied where applicable",
                             },
                             disputed_non_property_disregard: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Amount of subject matter of dispute deduction applied for assets other than property",
                             },
                             capital_contribution: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Duplicate of results_summary capital_contribution field",
                             },
                             combined_disputed_capital: {
                               description: "Combined applicant and partner disputed capital",
                               type: :number,
                               format: :decimal,
                             },
                             combined_non_disputed_capital: {
                               description: "Combined applicant and partner non-disputed capital",
                               type: :number,
                               format: :decimal,
                             },
                             combined_assessed_capital: {
                               type: :number,
                               format: :decimal,
                               minimum: 0,
                               description: "Amount of assessed capital for both client and partner",
                             },
                           },
                         },
                       ],
                     },
                     partner_capital: { "$ref": SCHEMA_COMPONENTS[:capital_result] },
                   },
                 },
                 assessment: {
                   type: :object,
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
                     applicant: { type: :object },
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
                         state_benefits: {
                           type: :object,
                           additionalProperties: false,
                           properties: {
                             monthly_equivalents: {
                               type: :object,
                               additionalProperties: false,
                               properties: {
                                 all_sources: {
                                   type: :number,
                                   format: :decimal,
                                 },
                                 cash_transactions: {
                                   type: :number,
                                   format: :decimal,
                                 },
                                 bank_transactions: {
                                   type: :array,
                                 },
                               },
                             },
                           },
                         },
                         other_income: { type: :object },
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
                     disposable_income: { type: :object },
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
                               items: { "$ref": SCHEMA_COMPONENTS[:non_property_asset] },
                             },
                             non_liquid: {
                               type: :array,
                               items: { "$ref": SCHEMA_COMPONENTS[:non_property_asset] },
                             },
                             vehicles: {
                               type: :array,
                               items: { "$ref": SCHEMA_COMPONENTS[:non_property_asset] },
                             },
                             properties: {
                               type: :object,
                               additionalProperties: false,
                               properties: {
                                 main_home: {
                                   "$ref" => SCHEMA_COMPONENTS[:property_result],
                                 },
                                 additional_properties: {
                                   type: :array,
                                   items: {
                                     "$ref" => SCHEMA_COMPONENTS[:property_result],
                                   },
                                 },
                               },
                             },
                           },
                         },
                       },
                     },
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
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-03-01", housing_cost_type: "rent" },
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-04-01", housing_cost_type: "rent" },
                    { amount: 10.00, client_id: SecureRandom.uuid, date: "2022-05-01", housing_cost_type: "rent" },
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
