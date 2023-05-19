require "swagger_helper"

RSpec.describe "full_assessment", :calls_bank_holiday, type: :request, swagger_doc: "v5/swagger.yaml" do
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
                  oneOf: [
                    {
                      type: :object,
                      required: %i[assessment applicant proceeding_types],
                      properties: {
                        assessment: { "$ref" => "#/components/schemas/CertificatedAssessment" },
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
                        properties: { "$ref" => "#/components/schemas/MainHomeAndOtherProperties" },
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
                        employment_or_self_employment: {
                          type: :array,
                          description: "One or more self employment details",
                          items: { "$ref" => "#/components/schemas/CertificatedSelfEmployment" },
                        },
                        partner: { "$ref" => "#/components/schemas/CertificatedPartner" },
                        explicit_remarks: { "$ref" => "#/components/schemas/ExplicitRemarks" },
                      },
                    },
                    {
                      type: :object,
                      required: %i[assessment applicant proceeding_types],
                      properties: {
                        assessment: { "$ref" => "#/components/schemas/ControlledAssessment" },
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
                        properties: { "$ref" => "#/components/schemas/MainHomeAndOtherProperties" },
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
                        employment_or_self_employment: {
                          type: :array,
                          description: "One or more self employment details",
                          items: { "$ref" => "#/components/schemas/ControlledSelfEmployment" },
                        },
                        partner: { "$ref" => "#/components/schemas/ControlledPartner" },
                        explicit_remarks: { "$ref" => "#/components/schemas/ExplicitRemarks" },
                      },
                    },
                  ],
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
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
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
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
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
                         { "$ref": "#/components/schemas/DisposableIncome" },
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
                               items: { "$ref": "#/components/schemas/ProceedingTypeResult" },
                             },
                           },
                         },
                       ],
                     },
                     partner_disposable_income: { "$ref": "#/components/schemas/DisposableIncome" },
                     capital: {
                       allOf: [
                         { "$ref": "#/components/schemas/CapitalResult" },
                         {
                           type: :object,
                           properties: {
                             proceeding_types: {
                               type: :array,
                               items: { "$ref": "#/components/schemas/ProceedingTypeResult" },
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
                     partner_capital: { "$ref": "#/components/schemas/CapitalResult" },
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
                       required: %i[employment_income irregular_income state_benefits other_income self_employments],
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
                         state_benefits: { type: :object },
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
                                   },
                                   tax: {
                                     type: :number,
                                     maximum: 0,
                                     format: :decimal,
                                   },
                                   benefits_in_kind: {
                                     type: :number,
                                     minimum: 0,
                                     format: :decimal,
                                   },
                                   national_insurance: {
                                     maximum: 0,
                                     type: :number,
                                     format: :decimal,
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
                               items: { "$ref": "#/components/schemas/NonPropertyAsset" },
                             },
                             non_liquid: {
                               type: :array,
                               items: { "$ref": "#/components/schemas/NonPropertyAsset" },
                             },
                             vehicles: {
                               type: :array,
                               items: { "$ref": "#/components/schemas/NonPropertyAsset" },
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
            employment_or_self_employment: [
              {
                income: {
                  receiving_only_statutory_sick_or_maternity_pay: false,
                  frequency: "monthly",
                  is_employment: true,
                  gross: 1000.0,
                  tax: 700.0,
                  national_insurance: 50.0,
                },
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
