require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/v6/assessments" do
    post("create") do
      tags "Perform assessment with single call"
      consumes "application/json"
      produces "application/json"

      description "Performs a complete assessment"

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[assessment applicant proceeding_types],
                  properties: {
                    assessment: { "$ref" => "#/components/schemas/Assessment" },
                    applicant: { "$ref" => "#/components/schemas/Applicant" },
                    proceeding_types: { "$ref" => "#/components/schemas/ProceedingTypes" },
                    capitals: { "$ref" => "#/components/schemas/Capitals" },
                    cash_transactions: { "$ref" => "#/components/schemas/CashTransactions" },
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: { "$ref" => "#/components/schemas/Dependant" },
                    },
                    employment_income: { "$ref" => "#/components/schemas/Employments" },
                    irregular_incomes: {
                      type: :object,
                      description: "A set of irregular income payments",
                      required: %i[payments],
                      additionalProperties: false,
                      example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                      properties: {
                        payments: { "$ref" => "#/components/schemas/IrregularIncomePayments" },
                      },
                    },
                    other_incomes: { "$ref" => "#/components/schemas/OtherIncomes" },
                    outgoings: { "$ref" => "#/components/schemas/OutgoingsList" },
                    properties: {
                      type: :object,
                      required: %i[main_home],
                      description: "A main home and additional properties",
                      properties: {
                        main_home: { "$ref" => "#/components/schemas/Property" },
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant",
                          items: { "$ref" => "#/components/schemas/Property" },
                        },
                      },
                    },
                    regular_transactions: {
                      type: :array,
                      description: "Zero or more regular transactions",
                      items: { "$ref" => "#/components/schemas/RegularTransaction" },
                    },
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits receved by the applicant and categorized by name",
                      items: { "$ref" => "#/components/schemas/StateBenefit" },
                    },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: { "$ref" => "#/components/schemas/Vehicle" },
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
                              description: "Whether the applicant's partner is employed",
                            },
                          },
                        },
                        irregular_incomes: { "$ref" => "#/components/schemas/IrregularIncomePayments" },
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
                              payments: { "$ref" => "#/components/schemas/EmploymentPaymentList" },
                            },
                          },
                        },
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
                        capital_items: { "$ref" => "#/components/schemas/Capitals" },
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
                    },
                    explicit_remarks: { "$ref" => "#/components/schemas/ExplicitRemarks" },
                  },
                }

      response(200, "successful") do
        schema type: :object,
               required: %i[timestamp result_summary assessment version success],
               properties: {
                 timestamp: {
                   type: :string,
                 },
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
                         capital_contribution: { type: :number },
                         income_contribution: { type: :number },
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                       },
                     },
                     gross_income: {
                       type: :object,
                       required: %i[total_gross_income combined_total_gross_income proceeding_types],
                       properties: {
                         total_gross_income: { type: :number },
                         combined_total_gross_income: { type: :number },
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                       },
                     },
                     partner_gross_income: {
                       type: :object,
                       required: %i[total_gross_income],
                       properties: {
                         total_gross_income: { type: :number },
                       },
                     },
                     disposable_income: {
                       type: :object,
                       properties: {
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                         income_contribution: { type: :number },
                         combined_total_outgoings_and_allowances: { type: :number },
                         total_disposable_income: { type: :number },
                         combined_total_disposable_income: { type: :number },
                         total_outgoings_and_allowances: { type: :number },
                         dependant_allowance: { type: :number },
                         gross_housing_costs: { type: :number },
                         housing_benefit: { type: :number },
                         net_housing_costs: { type: :number },
                         maintenance_allowance: { type: :number },
                         employment_income: { type: :object },
                         partner_allowance: { type: :number },
                       },
                     },
                     partner_disposable_income: {
                       type: :object,
                       properties: {
                         income_contribution: { type: :number },
                         total_disposable_income: { type: :number },
                         total_outgoings_and_allowances: { type: :number },
                         dependant_allowance: { type: :number },
                         gross_housing_costs: { type: :number },
                         housing_benefit: { type: :number },
                         net_housing_costs: { type: :number },
                         maintenance_allowance: { type: :number },
                         employment_income: { type: :object },
                       },
                     },
                     capital: {
                       type: :object,
                       additionalProperties: false,
                       properties: {
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                         total_liquid: {
                           type: :number,
                           description: "Total value of all client liquid assets in submission",
                           format: :decimal,
                         },
                         total_non_liquid: {
                           description: "Total value of all client non-liquid assets in submission",
                           type: :number,
                           format: :decimal,
                           minimum: 0.0,
                         },
                         total_vehicle: {
                           description: "Total value of all client vehicle assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         total_property: {
                           description: "Total value of all client property assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         total_mortgage_allowance: {
                           description: "Maxiumum mortgage allowance used in submission. Cases April 2020 will all be set to 999_999_999",
                           type: :number,
                           format: :decimal,
                         },
                         total_capital: {
                           description: "Total value of all capital assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         pensioner_capital_disregard: {
                           type: :number,
                           format: :decimal,
                           description: "Cap on pensioner capital disregard for this assessment (based on disposable_income)",
                           minimum: 0.0,
                         },
                         total_capital_with_smod: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of capital with subject matter of dispute deduction applied",
                         },
                         disputed_non_property_disregard: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of subject matter of dispute deduction applied for assets other than property",
                         },
                         pensioner_disregard_applied: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of pensioner capital disregard applied to this assessment",
                         },
                         subject_matter_of_dispute_disregard: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Total amount of subject matter of dispute disregard applied on this submission",
                         },
                         capital_contribution: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Assessed capital contribution. Will only be non-zero for 'contribution_required' cases",
                         },
                         assessed_capital: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of assessed client capital. Zero if deductions exceed total capital.",
                         },
                         combined_assessed_capital: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of assessed capital for both client and partner",
                         },
                       },
                     },
                     partner_capital: {
                       type: :object,
                       properties: {
                         total_liquid: { type: :number },
                         total_non_liquid: { type: :number },
                         total_vehicle: { type: :number },
                         total_property: { type: :number },
                         total_mortgage_allowance: { type: :number },
                         total_capital: { type: :number },
                         pensioner_capital_disregard: { type: :number },
                         subject_matter_of_dispute_disregard: { type: :number },
                         capital_contribution: { type: :number },
                         assessed_capital: { type: :number },
                       },
                     },
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
                     gross_income: { type: :object },
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
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             non_liquid: {
                               type: :array,
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             vehicles: {
                               type: :array,
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             properties: {
                               type: :object,
                               additionalProperties: false,
                               properties: {
                                 main_home: {
                                   "$ref" => "#/components/schemas/PropertyResult",
                                 },
                                 additional_properties: {
                                   type: :array,
                                   items: {
                                     "$ref" => "#/components/schemas/PropertyResult",
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
                 },
                 success: {
                   type: :boolean,
                 },
               }

        let(:params) do
          {
            assessment: { submission_date: "2022-06-06" },
            applicant: { date_of_birth: "2001-02-02", has_partner_opponent: false, receives_qualifying_benefit: false, employed: false },
            proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
            outgoings: [
              { name: "child_care", payments: [{ amount: 10.00, client_id: "blah", payment_date: "2022-05-06" }] },
              { name: "rent_or_mortgage", payments: [{ amount: 10.00, client_id: "blah", payment_date: "2022-05-06", housing_cost_type: "rent" }] },
            ],
            cash_transactions: {
              outgoings: [
                { category: "child_care",
                  payments: [{ amount: 10.00, client_id: "blah", date: "2022-03-01" },
                             { amount: 10.00, client_id: "blah", date: "2022-04-01" },
                             { amount: 10.00, client_id: "blah", date: "2022-05-01" }] },
                { category: "rent_or_mortgage",
                  payments: [
                    { amount: 10.00, client_id: "blah", date: "2022-03-01", housing_cost_type: "rent" },
                    { amount: 10.00, client_id: "blah", date: "2022-04-01", housing_cost_type: "rent" },
                    { amount: 10.00, client_id: "blah", date: "2022-05-01", housing_cost_type: "rent" },
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
