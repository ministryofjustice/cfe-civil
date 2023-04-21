# frozen_string_literal: true

require "rails_helper"
require "swagger_parameter_helpers"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger")

  api_description = <<~DESCRIPTION.chomp
    # Check financial eligibility for legal aid.

    ## Usage:
      - Create an assessment by POSTing a payload to `/assessments`
        and store the `assessment_id` returned.
      - Add assessment components, such as applicant, capitals and properties using the
        `assessment_id` from the first call
      - Retrieve the result using the GET `/assessments/{assessment_id}`
  DESCRIPTION

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v6/swagger.json'
  config.swagger_docs = {
    "v5/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "API V5",
        description: api_description,
        contact: {
          name: "Github repository",
          url: "https://github.com/ministryofjustice/cfe-civil",
        },
        version: "v5",
      },
      components: {
        schemas: {
          currency: {
            description: "A negative or positive number (including zero) with two decimal places",
            # legacy - some currency values are historically allowed as strings
            oneOf: [
              {
                type: :number,
                format: :decimal,
                multipleOf: 0.01,
              },
              {
                type: :string,
                pattern: "^[-+]?\\d+(\\.\\d{1,2})?$",
              },
            ],
          },
          positive_currency: {
            description: "Non-negative number (including zero) with two decimal places",
            oneOf: [
              {
                type: :number,
                format: :decimal,
                minimum: 0.0,
                multipleOf: 0.01,
              },
              {
                type: :string,
                pattern: "^[+]?\\d+(\\.\\d{1,2})?$",
              },
            ],
          },
          ProceedingTypeResult: {
            type: :object,
            required: %i[ccms_code client_involvement_type upper_threshold lower_threshold result],
            properties: {
              ccms_code: {
                type: :string,
                enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                description: "The code expected by CCMS",
              },
              client_involvement_type: {
                type: :string,
                enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                example: "A",
                description: "The client_involvement_type expected by CCMS",
              },
              upper_threshold: { type: :number },
              lower_threshold: { type: :number },
              result: {
                type: :string,
                enum: %w[eligible ineligible contribution_required],
              },
            },
          },
          PropertyResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              value: {
                type: :number,
                minimum: 0.0,
              },
              outstanding_mortgage: {
                type: :number,
                minimum: 0.0,
              },
              # The minimum has to be zero because we have to have a 'dummy' main home sometimes
              percentage_owned: {
                type: :integer,
                minimum: 0,
                maximum: 100,
              },
              main_home: {
                type: :boolean,
              },
              shared_with_housing_assoc: {
                type: :boolean,
              },
              transaction_allowance: {
                type: :number,
                minimum: 0.0,
              },
              allowable_outstanding_mortgage: {
                type: :number,
                minimum: 0.0,
              },
              net_value: {
                type: :number,
              },
              net_equity: {
                type: :number,
              },
              smod_allowance: {
                type: :number,
                description: "Amount of subject matter of dispute disregard applied to this property",
                minimum: 0.0,
                maximum: 100_000.0,
              },
              main_home_equity_disregard: {
                type: :number,
                description: "Amount of main home equity disregard applied to this property",
              },
              assessed_equity: {
                type: :number,
                minimum: 0.0,
              },
            },
          },
          BankAccounts: {
            type: :array,
            description: "Describes the name of the bank account and the lowest balance during the computation period",
            example: [{ value: 1.01, description: "test name 1", subject_matter_of_dispute: false },
                      { value: 100.01, description: "test name 2", subject_matter_of_dispute: true }],
            items: {
              type: :object,
              description: "Account detail",
              additionalProperties: false,
              required: %i[value description],
              properties: {
                value: { "$ref" => "#/components/schemas/currency" },
                description: {
                  type: :string,
                },
                subject_matter_of_dispute: {
                  description: "Whether the contents of this bank account are the subject of a dispute",
                  type: :boolean,
                },
              },
            },
          },
          Capitals: {
            type: :object,
            additionalProperties: false,
            properties: {
              bank_accounts: { "$ref" => "#/components/schemas/BankAccounts" },
              non_liquid_capital: {
                type: :array,
                description: "An array of objects describing applicant's non-liquid capital items (excluding property), e.g. valuable items, jewellery, trusts, other investments",
                example: [{ value: 1.01, description: "asset name 1", subject_matter_of_dispute: false },
                          { value: 100.01, description: "asset name 2", subject_matter_of_dispute: true }],
                items: {
                  type: :object,
                  description: "Asset detail",
                  required: %i[value description],
                  additionalProperties: false,
                  properties: {
                    value: { "$ref" => "#/components/schemas/positive_currency" },
                    description: {
                      description: "Definition of a non-liquid capital item",
                      type: :string,
                    },
                    subject_matter_of_dispute: {
                      description: "Whether the item is the subject of a dispute",
                      type: :boolean,
                    },
                  },
                },
              },
            },
          },
          EmploymentPaymentList: {
            type: :array,
            description: "One or more employment payment details",
            minItems: 1,
            items: {
              type: :object,
              additionalProperties: false,
              required: %i[client_id date gross benefits_in_kind tax national_insurance],
              properties: {
                client_id: {
                  type: :string,
                  description: "Client supplied id to identify the payment",
                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                },
                date: {
                  type: :string,
                  format: :date,
                  description: "Date payment received",
                  example: "1992-07-22",
                },
                gross: {
                  "$ref" => "#/components/schemas/positive_currency",
                  description: "Gross payment income received",
                  example: "101.01",
                },
                benefits_in_kind: {
                  "$ref" => "#/components/schemas/positive_currency",
                  description: "Benefit in kind amount received",
                },
                tax: {
                  "$ref" => "#/components/schemas/currency",
                  description: "Amount of tax paid - normally negative, but can be positive for a tax refund",
                  example: -10.01,
                },
                national_insurance: {
                  "$ref" => "#/components/schemas/currency",
                  description: "Amount of national insurance paid - normally negative, but can be positive for a tax refund",
                  example: -5.24,
                },
                net_employment_income: {
                  "$ref" => "#/components/schemas/currency",
                  description: "Deprecated field not used in calculation",
                },
              },
            },
          },
          Asset: {
            type: :object,
            additionalProperties: false,
            required: %i[value description],
            value: {
              type: :number,
              format: :decimal,
              description: "Value of asset",
            },
            description: {
              type: :number,
              format: :decimal,
              description: "Description of asset",
            },
          },
          Employments: {
            type: :array,
            description: "One or more employment income details",
            items: {
              type: :object,
              additionalProperties: false,
              required: %i[name client_id payments],
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
                receiving_only_statutory_sick_or_maternity_pay: {
                  type: :boolean,
                  description: "Client is in receipt only of Statutory Sick Pay (SSP) or Statutory Maternity Pay (SMP)",
                },
                payments: { "$ref" => "#/components/schemas/EmploymentPaymentList" },
              },
            },
          },
          OutgoingsList: {
            type: :array,
            description: "One or more outgoings categorized by name",
            items: {
              oneOf: [
                {
                  type: :object,
                  required: %i[name payments],
                  additionalProperties: false,
                  description: "Outgoing payments detail",
                  properties: {
                    name: {
                      type: :string,
                      enum: CFEConstants::NON_HOUSING_OUTGOING_CATEGORIES,
                      description: "Type of outgoing",
                      example: CFEConstants::NON_HOUSING_OUTGOING_CATEGORIES.first,
                    },
                    payments: {
                      type: :array,
                      description: "One or more outgoing payments detail",
                      items: {
                        type: :object,
                        additionalProperties: false,
                        required: %i[client_id payment_date amount],
                        description: "Payment detail",
                        properties: {
                          client_id: {
                            type: :string,
                            description: "Client identifier for outgoing payment",
                            example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                          },
                          payment_date: {
                            type: :string,
                            format: :date,
                            description: "Date payment made",
                            example: "1992-07-22",
                          },
                          amount: {
                            type: :number,
                            format: :decimal,
                            description: "Amount of payment made",
                            example: 101.01,
                          },
                        },
                      },
                    },
                  },
                },
                {
                  type: :object,
                  required: %i[name payments],
                  additionalProperties: false,
                  description: "Outgoing payments detail",
                  properties: {
                    name: {
                      type: :string,
                      enum: %w[rent_or_mortgage],
                      description: "Type of outgoing",
                    },
                    payments: {
                      type: :array,
                      description: "One or more outgoing payments detail",
                      items: {
                        type: :object,
                        additionalProperties: false,
                        required: %i[client_id payment_date amount housing_cost_type],
                        description: "Payment detail",
                        properties: {
                          client_id: {
                            type: :string,
                            description: "Client identifier for outgoing payment",
                            example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                          },
                          payment_date: {
                            type: :string,
                            format: :date,
                            description: "Date payment made",
                            example: "1992-07-22",
                          },
                          housing_cost_type: {
                            type: :string,
                            enum: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES,
                            description: "Housing cost type",
                          },
                          amount: {
                            type: :number,
                            format: :decimal,
                            description: "Amount of payment made",
                            example: 101.01,
                          },
                        },
                      },
                    },
                  },
                },
              ],
            },
          },
          Applicant: {
            type: :object,
            description: "Object describing pertinent applicant details",
            required: %i[date_of_birth has_partner_opponent receives_qualifying_benefit],
            additionalProperties: false,
            properties: {
              date_of_birth: { type: :string,
                               format: :date,
                               example: "1992-07-22",
                               description: "Applicant date of birth" },
              employed: {
                oneOf: [{ type: :boolean }, { type: :null }],
                example: true,
              },
              has_partner_opponent: { type: :boolean,
                                      example: false,
                                      description: "Applicant has partner opponent (unused in calculation)" },
              receives_qualifying_benefit: { type: :boolean,
                                             example: false,
                                             description: "Applicant receives qualifying benefit" },
              receives_asylum_support: { type: :boolean,
                                         example: false,
                                         description: "Applicant receives section 4 or section 95 Asylum Support" },
              involvement_type: {
                type: :string,
                "enum": %w[applicant],
              },
            },
          },
          Assessment: {
            type: :object,
            additionalProperties: false,
            required: %i[submission_date],
            properties: {
              client_reference_id: {
                type: :string,
                example: "LA-FOO-BAR",
                description: "Client's reference number for this application (free text)",
              },
              submission_date: {
                type: :string,
                description: "Date of the original submission (iso8601 format)",
                example: "2022-05-19",
              },
              level_of_help: {
                type: :string,
                enum: Assessment.levels_of_help.keys,
                example: Assessment.levels_of_help.keys.first,
                description: "The level of help required by the client. Defaults to 'certificated'",
              },
            },
          },
          CashTransactions: {
            type: :object,
            description: "A set of cash income[ings] and outgoings payments by category",
            example: JSON.parse(File.read(Rails.root.join("spec/fixtures/cash_transactions.json"))
                                      .gsub("3.months.ago", "2022-01-01")
                                      .gsub("2.months.ago", "2022-02-01")
                                      .gsub("1.month.ago", "2022-03-01")),
            properties: {
              income: {
                type: :array,
                description: "One or more income details",
                items: {
                  type: :object,
                  description: "Income detail",
                  additionalProperties: false,
                  required: %i[category payments],
                  properties: {
                    category: {
                      type: :string,
                      enum: CFEConstants::VALID_INCOME_CATEGORIES,
                      example: CFEConstants::VALID_INCOME_CATEGORIES.first,
                    },
                    payments: {
                      type: :array,
                      description: "One or more payment details",
                      items: {
                        type: :object,
                        description: "Payment detail",
                        additionalProperties: false,
                        required: %i[amount client_id date],
                        properties: {
                          date: {
                            type: :string,
                            format: :date,
                            example: "1992-07-22",
                          },
                          amount: { "$ref" => "#/components/schemas/positive_currency" },
                          client_id: {
                            type: :string,
                            format: :uuid,
                            example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                          },
                        },
                      },
                    },
                  },
                },
              },
              outgoings: {
                type: :array,
                items: {
                  type: :object,
                  additionalProperties: false,
                  required: %i[category payments],
                  properties: {
                    category: {
                      description: "The category of the outgoing transaction",
                      type: :string,
                      enum: %w[child_care rent_or_mortgage maintenance_out legal_aid],
                    },
                    payments: {
                      description: "The payments of the outgoing transaction",
                      type: :array,
                      items: {
                        type: :object,
                        required: %i[amount client_id date],
                        properties: {
                          amount: { "$ref" => "#/components/schemas/positive_currency" },
                          client_id: { type: :string },
                          date: {
                            type: "string",
                            format: "date",
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          Dependant: {
            type: :object,
            required: %i[date_of_birth in_full_time_education relationship],
            properties: {
              date_of_birth: {
                type: :string,
                format: :date,
                example: "1992-07-22",
              },
              in_full_time_education: {
                type: :boolean,
                example: false,
                description: "Dependant is in full time education or not",
              },
              relationship: {
                type: :string,
                enum: Dependant.relationships.values,
                example: Dependant.relationships.values.first,
                description: "Dependant's relationship to the applicant",
              },
              monthly_income: {
                "$ref" => "#/components/schemas/currency",
                description: "Dependant's monthly income",
              },
              assets_value: {
                "$ref" => "#/components/schemas/currency",
                description: "Dependant's total assets value",
              },
            },
          },
          IrregularIncomePayments: {
            type: :array,
            minItems: 0,
            maxItems: 2,
            description: "One or more irregular payment details",
            items: {
              type: :object,
              required: %i[income_type frequency amount],
              description: "Irregular payment detail",
              properties: {
                income_type: {
                  type: :string,
                  enum: CFEConstants::VALID_IRREGULAR_INCOME_TYPES,
                  description: "Identifying name for this irregular income payment",
                  example: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.first,
                },
                frequency: {
                  type: :string,
                  enum: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES,
                  description: "Frequency of the payment received",
                  example: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES.first,
                },
                amount: { "$ref" => "#/components/schemas/currency" },
              },
            },
          },
          OtherIncomes: {
            type: :array,
            description: "One or more other regular income payments categorized by source",
            items: {
              type: :object,
              description: "Other regular income detail",
              required: %i[source payments],
              properties: {
                source: {
                  type: :string,
                  enum: CFEConstants::HUMANIZED_INCOME_CATEGORIES,
                  description: "Source of other regular income",
                  example: CFEConstants::HUMANIZED_INCOME_CATEGORIES.first,
                },
                payments: {
                  type: :array,
                  description: "One or more other regular payment details",
                  items: {
                    type: :object,
                    description: "Payment detail",
                    required: %i[date amount client_id],
                    properties: {
                      date: {
                        type: :string,
                        format: :date,
                        description: "Date payment received",
                        example: "1992-07-22",
                      },
                      amount: {
                        "$ref" => "#/components/schemas/positive_currency",
                        description: "Amount of payment received",
                      },
                      client_id: {
                        type: :string,
                        format: :uuid,
                        description: "Client identifier for payment received",
                        example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                      },
                    },
                  },
                },
              },
            },
          },
          ProceedingTypes: {
            type: :array,
            minItems: 1,
            description: "One or more proceeding_type details",
            items: {
              type: :object,
              required: %i[ccms_code client_involvement_type],
              properties: {
                ccms_code: {
                  type: :string,
                  enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                  example: "DA001",
                  description: "The code expected by CCMS",
                },
                client_involvement_type: {
                  type: :string,
                  enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                  example: "A",
                  description: "The client_involvement_type expected by CCMS",
                },
              },
            },
          },
          Property: {
            type: :object,
            required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
            properties: {
              value: {
                "$ref" => "#/components/schemas/currency",
                description: "Financial value of the property",
              },
              outstanding_mortgage: {
                "$ref" => "#/components/schemas/currency",
                description: "Amount outstanding on all mortgages against this property",
              },
              percentage_owned: {
                type: :number,
                format: :decimal,
                description: "Percentage share of the property which is owned by the applicant",
                example: 99.99,
                minimum: 0,
                maximum: 100,
              },
              shared_with_housing_assoc: {
                type: :boolean,
                description: "Property is shared with a housing association",
              },
              subject_matter_of_dispute: {
                type: :boolean,
                description: "Property is the subject of a dispute",
              },
            },
          },
          RegularTransaction: {
            type: :object,
            description: "regular transaction detail",
            required: %i[category operation frequency amount],
            additionalProperties: false,
            properties: {
              category: {
                type: :string,
                enum: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES + CFEConstants::VALID_OUTGOING_CATEGORIES,
                description: "Identifying category for this regular transaction",
                example: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES.first,
              },
              operation: {
                type: :string,
                enum: %w[credit debit],
                description: "Identifying operation for this regular transaction",
                example: "credit",
              },
              frequency: {
                type: :string,
                enum: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES,
                description: "Frequency with which regular transaction is made or received",
                example: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.first,
              },
              amount: { "$ref" => "#/components/schemas/currency" },
            },
          },
          StateBenefit: {
            type: :object,
            required: %i[name payments],
            additionalProperties: false,
            description: "State benefit payment detail",
            properties: {
              name: {
                type: :string,
                description: "Name of the state benefit",
                example: "my_state_bnefit",
              },
              payments: {
                type: :array,
                description: "One or more state benefit payments details",
                items: {
                  required: %i[client_id date amount],
                  additionalProperties: false,
                  type: :object,
                  description: "Payment detail",
                  properties: {
                    client_id: {
                      type: :string,
                      format: :uuid,
                      description: "Client identifier for payment received",
                      example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                    },
                    date: {
                      type: :string,
                      format: :date,
                      description: "Date payment received",
                      example: "1992-07-22",
                    },
                    amount: {
                      "$ref" => "#/components/schemas/currency",
                      description: "Amount of payment received",
                    },
                    flags: {
                      type: :object,
                      description: "Line items that should be flagged to caseworkers for review",
                      example: { multi_benefit: true },
                      properties: {
                        multi_benefit: {
                          type: :boolean,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          Vehicle: {
            type: :object,
            required: %i[value date_of_purchase],
            properties: {
              value: {
                "$ref" => "#/components/schemas/positive_currency",
                description: "Financial value of the vehicle",
              },
              loan_amount_outstanding: {
                "$ref" => "#/components/schemas/currency",
                description: "Amount remaining, if any, of a loan used to purchase the vehicle",
              },
              date_of_purchase: {
                type: :string,
                format: :date,
                description: "Date vehicle purchased by the applicant",
              },
              in_regular_use: {
                type: :boolean,
                description: "Vehicle in regular use or not",
              },
              subject_matter_of_dispute: {
                type: :boolean,
                description: "Whether this vehicle is the subject of a dispute",
              },
            },
          },
          ExplicitRemarks: {
            type: :array,
            description: "One or more remarks by category",
            items: {
              type: :object,
              required: %i[category details],
              description: "Explicit remark",
              properties: {
                category: {
                  type: :string,
                  enum: CFEConstants::VALID_REMARK_CATEGORIES,
                  description: "Category of remark. Currently, only 'policy_disregard' is supported",
                  example: CFEConstants::VALID_REMARK_CATEGORIES.first,
                },
                details: {
                  type: :array,
                  description: "One or more remarks for that category",
                  items: {
                    type: :string,
                  },
                },
              },
            },
          },
        },
      },
      paths: {},
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml

  # mixin custom application specific swagger helpers
  config.extend SwaggerParameterHelpers, type: :request
end
