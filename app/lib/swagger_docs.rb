class SwaggerDocs
  SCHEMA_COMPONENTS = {
    assessment: "#/components/schemas/Assessment",
    v6_applicant: "#/components/schemas/v6/Applicant",
    v7_applicant: "#/components/schemas/v7/Applicant",
    v6_proceeding_types: "#/components/schemas/v6/ProceedingTypes",
    v7_proceeding_types: "#/components/schemas/v7/ProceedingTypes",
    capitals: "#/components/schemas/Capitals",
    cash_transactions: "#/components/schemas/CashTransactions",
    v6_dependants: "#/components/schemas/v6/Dependants",
    v7_dependants: "#/components/schemas/v7/Dependants",
    v6_employments: "#/components/schemas/v6/Employments",
    v7_employments: "#/components/schemas/v7/Employments",
    irregular_income_payments: "#/components/schemas/IrregularIncomePayments",
    other_incomes: "#/components/schemas/OtherIncomes",
    outgoings_list: "#/components/schemas/OutgoingsList",
    regular_transaction: "#/components/schemas/RegularTransaction",
    state_benefit: "#/components/schemas/StateBenefit",
    vehicle: "#/components/schemas/Vehicle",
    employment_details: "#/components/schemas/EmploymentDetails",
    self_employment: "#/components/schemas/SelfEmployment",
    explicit_remarks: "#/components/schemas/ExplicitRemarks",
    capital_result: "#/components/schemas/CapitalResult",
    v6_applicant_capital_result: "#/components/schemas/v6/ApplicantCapitalResult",
    v7_applicant_capital_result: "#/components/schemas/v7/ApplicantCapitalResult",
    property_result: "#/components/schemas/PropertyResult",
    disposable_income: "#/components/schemas/DisposableIncome",
    v6_applicant_disposable_income: "#/components/schemas/v6/ApplicantDisposableIncome",
    v7_applicant_disposable_income: "#/components/schemas/v7/ApplicantDisposableIncome",
    property: "#/components/schemas/Property",
    main_home: "#/components/schemas/MainHome",
    v6_proceeding_type_results: "#/components/schemas/v6/ProceedingTypeResults",
    v7_proceeding_type_results: "#/components/schemas/v7/ProceedingTypeResults",
    non_property_asset: "#/components/schemas/NonPropertyAsset",
    currency: "#/components/schemas/currency",
    numeric_currency: "#/components/schemas/numeric_currency",
    string_currency: "#/components/schemas/string_currency",
    positive_currency: "#/components/schemas/positive_currency",
    applicant_result: "#/components/schemas/ApplicantResult",
    remarks: "#/components/schemas/Remarks",
    outgoing_result: "#/components/schemas/OutgoingResult",
    state_benefits_result: "#/components/schemas/StateBenefitsResult",
    other_income_result: "#/components/schemas/OtherIncomeResult",
    disposable_income_result: "#/components/schemas/DisposableIncomeResult",
    gross_income_result: "#/components/schemas/GrossIncomeResult",
    overall_result: "#/components/schemas/OverallResult",
    income_contribution: "#/components/schemas/IncomeContribution",
    capital_contribution: "#/components/schemas/CapitalContribution",
    assessment_capital_result: "#/components/schemas/AssessmentCapitalResult",
    employment_details_result: "#/components/schemas/EmploymentDetailsResult",
  }.freeze

  attr_reader :version

  MSVCC_TEXT = [
    "<p>Do not include “disregarded payments” - those which should be excluded from the gross income and disposable income calculations, as described in the Lord Chancellor's guidance - certificated: ‘5.3 Disregarded payments', controlled: '5.4 Disregarded income’.</p>",
    "<p>Note: for submissions after MTR Phase 2 is implemented, “disregarded payments” will be extended to cover “Modern Slavery Victim Care Contract (MSVCC) financial support payments”, and no longer cover “Back to Work Bonus payments”</p>",
  ].join

  INACCESSIBLE_CAPITAL_TEXT = [
    "<p>Inaccessible capital - For submissions after MTR Phase 2 is implemented, capital where the value cannot be accessed to pay legal costs, should be excluded.</p>",
    "<p>Detailed guidance TBD</p>",
  ].join

  def initialize(version:)
    @version = version
  end

  def api_description
    <<~DESCRIPTION.chomp
      # CFE-Civil - Check Financial Eligibility for Civil legal aid

      ## Usage:
        - Calculate eligibility by POSTing a payload to `/#{@version}/assessments`
        - Add assessment components, such as applicant, capitals and properties in the payload
    DESCRIPTION
  end

  def strict_schema
    add_additional_property(schema)
  end

  def add_additional_property(object)
    object[:additionalProperties] = false if (object.key? :type) && (object.value? :object)
    object.transform_values do |value|
      case value
      when Hash
        add_additional_property(value)
      when Array
        value.select { |v| v.is_a?(Hash) }.each { |item| add_additional_property(item) }
      else
        value
      end
    end
    object
  end

  def schema
    {
      openapi: "3.0.1",
      info: {
        title: "API #{version}",
        description: api_description,
        contact: {
          name: "Github repository",
          url: "https://github.com/ministryofjustice/cfe-civil",
        },
        version:,
      },
      components: {
        schemas: {
          currency: {
            # description: "A negative or positive number (including zero) with two decimal places",
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
            example: 70.25,
          },
          numeric_currency: {
            description: "Currency as number",
            type: :number,
            format: :decimal,
            multipleOf: 0.01,
          },
          string_currency: {
            description: "Currency as string",
            type: :string,
            pattern: "^[-+]?\\d+(\\.\\d{1,2})?$",
          },
          positive_currency: {
            # description: "Non-negative number (including zero) with two decimal places",
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
            example: 60.99,
          },
          OverallResult: {
            type: :string,
            enum: %w[eligible ineligible contribution_required],
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
                type: :number,
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
              subject_matter_of_dispute: {
                type: :boolean,
                nullable: true,
              },
            },
          },
          BankAccounts: {
            type: :array,
            description: ["Describes the name of the bank account and the lowest balance during the computation period", INACCESSIBLE_CAPITAL_TEXT].join,
            example: [{ value: 1.01, description: "test name 1", subject_matter_of_dispute: false },
                      { value: 100.01, description: "test name 2", subject_matter_of_dispute: true }],
            items: {
              type: :object,
              description: "Account detail",
              additionalProperties: false,
              required: %i[value description],
              properties: {
                value: { "$ref" => SCHEMA_COMPONENTS[:currency] },
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
                  description: ["Asset detail", INACCESSIBLE_CAPITAL_TEXT].join,
                  required: %i[value description],
                  additionalProperties: false,
                  properties: {
                    value: { "$ref" => SCHEMA_COMPONENTS[:positive_currency] },
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
          NonPropertyAsset: {
            type: :object,
            additionalProperties: false,
            description: "Non-property Asset",
            required: %i[value description],
            properties: {
              value: {
                type: :number,
                format: :decimal,
                description: "Value of asset",
              },
              description: {
                type: :string,
                description: "Description of asset",
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
                  description: "Outgoing payments detail. 'priority_debt_repayment' and 'council_tax' are not calculated before MTR",
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
                        properties: {
                          client_id: {
                            type: :string,
                            description: "Client identifier for outgoing payment",
                            example: "05459c0f-a620-4743-9f0c-b3daa93e57",
                          },
                          payment_date: {
                            type: :string,
                            format: :date,
                            description: "Date payment made",
                            example: "1992-07-23",
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
                        properties: {
                          client_id: {
                            type: :string,
                            description: "Client identifier for outgoing payment",
                            example: "05459c0f-a620-4743-9f0c-b3daa93e5",
                          },
                          payment_date: {
                            type: :string,
                            format: :date,
                            description: "Date payment made",
                            example: "1992-07-24",
                          },
                          housing_cost_type: {
                            type: :string,
                            enum: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES,
                            description: "Housing cost type - should also be in cash_transactions.outgoings, but currently unused by both clients",
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
                format: :date,
                description: "Date of the original submission (iso8601 format)",
                example: "2022-05-19",
              },
              level_of_help: {
                type: :string,
                enum: Assessment::LEVELS_OF_HELP,
                example: Assessment::LEVELS_OF_HELP.first,
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
                      description: MSVCC_TEXT,
                    },
                    payments: {
                      type: :array,
                      description: "One or more payment details",
                      items: {
                        type: :object,
                        additionalProperties: false,
                        required: %i[amount client_id date],
                        properties: {
                          date: {
                            type: :string,
                            format: :date,
                            example: "1992-07-26",
                          },
                          amount: { "$ref" => SCHEMA_COMPONENTS[:positive_currency] },
                          client_id: {
                            type: :string,
                            format: :uuid,
                            example: "05459c0f-a620-4743-9f0c-b3daa93e",
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
                      description: "The category of the outgoing transaction. 'priority_debt_repayment' and 'council_tax' are not calculated before MTR",
                      type: :string,
                      enum: CFEConstants::VALID_OUTGOING_CATEGORIES,
                    },
                    payments: {
                      description: "The payments of the outgoing transaction",
                      type: :array,
                      items: {
                        type: :object,
                        required: %i[amount client_id date],
                        properties: {
                          amount: { "$ref" => SCHEMA_COMPONENTS[:positive_currency] },
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
          DateOfBirth: {
            type: :string,
            format: :date,
            example: "1992-07-27",
          },
          InFullTimeEducation: {
            type: :boolean,
            example: false,
            description: "Dependant is in full time education or not",
          },
          RelationShip: {
            type: :string,
            enum: %i[child_relative adult_relative],
            description: "Dependant's relationship to the applicant",
          },
          DependantIncome: {
            type: :object,
            required: %i[frequency amount],
            additionalProperties: false,
            properties: {
              frequency: {
                type: :string,
                enum: EmploymentOrSelfEmploymentIncome::PAYMENT_FREQUENCIES,
              },
              amount: {
                oneOf: [
                  { "$ref" => SCHEMA_COMPONENTS[:numeric_currency] },
                ],
                example: 0,
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
                amount: { "$ref" => SCHEMA_COMPONENTS[:currency] },
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
                    required: %i[date amount client_id],
                    properties: {
                      date: {
                        type: :string,
                        format: :date,
                        example: "1992-07-28",
                      },
                      amount: {
                        oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:positive_currency] }], # "oneOf" hack
                        description: "Amount of payment received",
                      },
                      client_id: {
                        type: :string,
                        format: :uuid,
                        description: "Client identifier for payment received",
                        example: "05459c0f-a620-4743-9f0c-b3daa93e",
                      },
                    },
                  },
                },
              },
            },
          },
          Property: {
            type: :object,
            description: ["Details of property", INACCESSIBLE_CAPITAL_TEXT].join,
            required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
            properties: {
              value: {
                oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                description: "Financial value of the property",
              },
              outstanding_mortgage: {
                oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
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
                description: "Property is the subject of a dispute. Defaults to false",
              },
            },
          },
          MainHome: {
            oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:property] }],
            description: ["Property where applicant is living, or original main property in a domestic abuse case", INACCESSIBLE_CAPITAL_TEXT].join,
          },
          RegularTransaction: {
            type: :object,
            description: "Regular transaction detail. 'priority_debt_repayment' and 'council_tax' are not calculated before MTR",
            required: %i[category operation frequency amount],
            additionalProperties: false,
            properties: {
              category: {
                type: :string,
                enum: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES + CFEConstants::VALID_OUTGOING_CATEGORIES,
                description: ["Identifying category for this regular transaction", MSVCC_TEXT].join,
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
              amount: { "$ref" => SCHEMA_COMPONENTS[:currency] },
            },
          },
          SelfEmployment: {
            type: :object,
            required: %i[income],
            additionalProperties: false,
            description: "Self employment, with pay info supplied in the 'how much, how often' pattern",
            properties: {
              client_reference: {
                type: :string,
                description: "Optional reference, echoed in response",
              },
              income: {
                type: :object,
                required: %i[frequency gross tax national_insurance],
                additionalProperties: false,
                properties: {
                  frequency: {
                    type: :string,
                    enum: EmploymentOrSelfEmploymentIncome::PAYMENT_FREQUENCIES,
                  },
                  gross: {
                    type: :number,
                    format: :decimal,
                    minimum: 0,
                    description: "Gross income from this undertaking",
                  },
                  tax: {
                    type: :number,
                    format: :decimal,
                    maximum: 0,
                    description: "Tax paid (negative) on this income",
                  },
                  national_insurance: {
                    type: :number,
                    maximum: 0,
                    format: :decimal,
                    description: "NI paid (negative) on this income",
                  },
                  prisoner_levy: {
                    type: :number,
                    maximum: 0,
                    format: :decimal,
                    description: "prisoner levy paid (negative) on this income",
                  },
                  student_debt_repayment: {
                    type: :number,
                    maximum: 0,
                    format: :decimal,
                    description: "student debt repayment paid (negative) on this income",
                  },
                },
              },
            },
          },
          EmploymentDetails: {
            type: :object,
            required: %i[income],
            additionalProperties: false,
            description: "Employment, with pay info supplied in the 'how much, how often' pattern",
            properties: {
              client_reference: {
                type: :string,
                description: "Optional reference, echoed in response",
              },
              income: {
                type: :object,
                required: %i[frequency gross tax benefits_in_kind national_insurance receiving_only_statutory_sick_or_maternity_pay],
                additionalProperties: false,
                properties: {
                  receiving_only_statutory_sick_or_maternity_pay: { type: :boolean },
                  frequency: {
                    type: :string,
                    enum: EmploymentOrSelfEmploymentIncome::PAYMENT_FREQUENCIES,
                  },
                  gross: {
                    type: :number,
                    format: :decimal,
                    minimum: 0,
                    description: "Gross income from this employment",
                    example: "2000.00",
                  },
                  benefits_in_kind: {
                    type: :number,
                    format: :decimal,
                    minimum: 0,
                    description: "Regular benefits in kind from this employment",
                  },
                  tax: {
                    type: :number,
                    format: :decimal,
                    maximum: 0,
                    description: "tax paid (negative) on this employment",
                  },
                  national_insurance: {
                    type: :number,
                    format: :decimal,
                    maximum: 0,
                    description: "NI paid (negative) on this employment",
                  },
                  prisoner_levy: {
                    type: :number,
                    format: :decimal,
                    maximum: 0,
                    description: "prisoner levy paid (negative) on this employment",
                  },
                  student_debt_repayment: {
                    type: :number,
                    maximum: 0,
                    format: :decimal,
                    description: "student debt repayment paid (negative) on this income",
                  },
                },
              },
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
                description: ["Name of the state benefit", MSVCC_TEXT].join,
                example: "my_state_benefit",
              },
              payments: {
                type: :array,
                description: "One or more state benefit payments details",
                items: {
                  required: %i[client_id date amount],
                  additionalProperties: false,
                  type: :object,
                  properties: {
                    client_id: {
                      type: :string,
                      format: :uuid,
                      description: "Client identifier for payment received",
                      example: "05459c0f-a620-4743-9f0c-b3daa9",
                    },
                    date: {
                      type: :string,
                      format: :date,
                      example: "1992-07-29",
                    },
                    amount: {
                      oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
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
            description: ["Detail of vehicle", INACCESSIBLE_CAPITAL_TEXT].join,
            required: %i[value date_of_purchase],
            properties: {
              value: {
                oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:positive_currency] }], # "oneOf" hack
                description: "Financial value of the vehicle",
              },
              loan_amount_outstanding: {
                oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
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
          TotalLiquidCapital: {
            type: :number,
            description: "Total value of all liquid assets in submission",
            format: :decimal,
          },
          TotalNonLiquidCapital: {
            description: "Total value of all non-liquid assets in submission",
            type: :number,
            format: :decimal,
            minimum: 0.0,
          },
          TotalVehicleCapital: {
            description: "Total value of all client vehicle assets in submission",
            type: :number,
            format: :decimal,
          },
          TotalPropertyCapital: {
            description: "Total value of all client property assets in submission",
            type: :number,
            format: :decimal,
          },
          TotalCapital: {
            description: "Total value of all capital assets in submission",
            type: :number,
            format: :decimal,
          },
          TotalCapitalWithSmod: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Total of all capital but with subject matter of dispute deduction applied where applicable",
          },
          TotalMortgageAllowance: {
            description: "Maximum mortgage allowance used in submission. Cases post-April 2020 will all be set to 999_999_999",
            type: :number,
            format: :decimal,
          },
          SmodDisregard: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Total amount of subject matter of dispute disregard applied on this submission",
          },
          AssessedCapital: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of assessed client capital. Zero if deductions exceed total capital.",
          },
          DisputedNonPropertyDisregard: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of subject matter of dispute deduction applied for assets other than property",
          },
          PensionerDisregardApplied: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of pensioner capital disregard applied to this assessment",
          },
          CapitalResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              total_liquid: { "$ref": "#/components/schemas/TotalLiquidCapital" },
              total_non_liquid: { "$ref": "#/components/schemas/TotalNonLiquidCapital" },
              total_vehicle: { "$ref": "#/components/schemas/TotalVehicleCapital" },
              total_property: { "$ref": "#/components/schemas/TotalPropertyCapital" },
              total_capital: { "$ref": "#/components/schemas/TotalCapital" },
              total_capital_with_smod: { "$ref": "#/components/schemas/TotalCapitalWithSmod" },
              total_mortgage_allowance: { "$ref": "#/components/schemas/TotalMortgageAllowance" },
              subject_matter_of_dispute_disregard: { "$ref": "#/components/schemas/SmodDisregard" },
              assessed_capital: { "$ref": "#/components/schemas/AssessedCapital" },
              disputed_non_property_disregard: { "$ref": "#/components/schemas/DisputedNonPropertyDisregard" },
              pensioner_disregard_applied: { "$ref": "#/components/schemas/PensionerDisregardApplied" },
            },
          },
          PensionerCapitalDisregard: {
            type: :number,
            format: :decimal,
            description: "Cap on pensioner capital disregard for this assessment (based on disposable_income)",
            minimum: 0.0,
          },
          CapitalContribution: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of capital contribution required (only valid if result is contribution_required)",
          },
          CombinedDisputedCapital: {
            description: "Combined applicant and partner disputed capital",
            type: :number,
            format: :decimal,
          },
          CombinedNonDisputedCapital: {
            description: "Combined applicant and partner non-disputed capital",
            type: :number,
            format: :decimal,
          },
          CombinedAssessedCapital: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of assessed capital for both client and partner",
          },
          EmploymentIncomeResult: {
            type: :object,
            description: "Calculated monthly employment income",
            additionalProperties: false,
            properties: {
              gross_income: { type: :number },
              benefits_in_kind: { type: :number },
              tax: {
                type: :number,
                format: :decimal,
                maximum: 0,
                description: "(negative) monthly tax paid",
              },
              national_insurance: {
                type: :number,
                format: :decimal,
                maximum: 0,
                description: "(negative) monthly NI paid",
              },
              prisoner_levy: {
                type: :number,
                format: :decimal,
                maximum: 0,
                description: "(negative) monthly prisoner levy paid",
              },
              student_debt_repayment: {
                type: :number,
                format: :decimal,
                maximum: 0,
                description: "(negative) monthly student debt repayment",
              },
              fixed_employment_deduction: {
                type: :number,
                format: :decimal,
                maximum: 0,
                description: "(negative) fixed employment deduction (if applicable) otherwise zero",
              },
              net_employment_income: {
                type: :number,
                description: "Calculated monthly net income (gross + benefits_in_kind - tax - ni - deductions)",
              },
            },
          },
          HousingCosts: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Calculated monthly rent/mortgage costs",
          },
          HousingBenefit: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Calculated monthly housing benefit received",
          },
          AllowedHousingCosts: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Calculated monthly allowed housing costs",
          },
          MaintenanceAllowance: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Total of maintenance outgoings costs",
          },
          DependantAllowanceUnder16: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Allowance for dependants under 16",
          },
          DependantAllowanceOver16: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Allowance for dependants 16 and over",
          },
          DependantAllowance: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Sum of dependant_allowance_under_16 and dependant_allowance_over_16",
          },
          TotalOutgoingsAndAllowances: {
            type: :number,
            format: :decimal,
            description: "Sum of outgoings and allowances",
          },
          TotalDisposableIncome: {
            type: :number,
            format: :decimal,
            description: "Calculated monthly disposable income (gross - outgoings - allowances)",
          },
          IncomeContribution: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Amount of income contribution required (only valid if result is contribution_required)",
          },
          DisposableIncome: {
            type: :object,
            additionalProperties: false,
            properties: {
              employment_income: { "$ref": "#/components/schemas/EmploymentIncomeResult" },
              housing_costs: { "$ref": "#/components/schemas/HousingCosts" },
              housing_benefit: { "$ref": "#/components/schemas/HousingBenefit" },
              gross_housing_costs: {
                allOf: [
                  { "$ref": "#/components/schemas/HousingCosts" },
                  { deprecated: true },
                ],
              },
              net_housing_costs: {
                allOf: [
                  { "$ref": "#/components/schemas/AllowedHousingCosts" },
                  { deprecated: true },
                ],
              },
              allowed_housing_costs: { "$ref": "#/components/schemas/AllowedHousingCosts" },
              maintenance_allowance: { "$ref": "#/components/schemas/MaintenanceAllowance" },
              dependant_allowance_under_16: { "$ref": "#/components/schemas/DependantAllowanceUnder16" },
              dependant_allowance_over_16: { "$ref": "#/components/schemas/DependantAllowanceOver16" },
              dependant_allowance: { "$ref": "#/components/schemas/DependantAllowance" },
              total_outgoings_and_allowances: { "$ref": "#/components/schemas/TotalOutgoingsAndAllowances" },
              total_disposable_income: { "$ref": "#/components/schemas/TotalDisposableIncome" },
            },
          },
          PartnerAllowance: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Fixed allowance given if applicant has a partner for means assessment purposes",
          },
          LoneParentAllowance: {
            type: :number,
            format: :decimal,
            minimum: 0,
            description: "Fixed allowance given if applicant is a lone parent",
          },
          CombinedOutgoingsAndAllowances: {
            type: :number,
            format: :decimal,
            description: "total_outgoings_and_allowances + partner total_outgoings_and_allowances",
          },
          CombinedDisposableIncome: {
            type: :number,
            format: :decimal,
            description: "total_disposable_income + partner total_disposable_income",
          },
          ApplicantResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              date_of_birth: {
                type: :string,
                format: :date,
              },
              involvement_type: { type: :string },
              employed: { type: :boolean },
              has_partner_opponent: { type: :boolean },
              receives_qualifying_benefit: { type: :boolean },
            },
          },
          ClientIdArray: {
            type: :array,
            description: "Array of client_ids affected by remark",
            items: { type: :string },
          },
          AmountVariationRemark: {
            type: :object,
            additionalProperties: false,
            properties: {
              amount_variation: { "$ref": "#/components/schemas/ClientIdArray" },
              unknown_frequency: { "$ref": "#/components/schemas/ClientIdArray" },
              multi_benefit: { "$ref": "#/components/schemas/ClientIdArray" },
            },
          },
          Remarks: {
            type: :object,
            additionalProperties: false,
            properties: {
              employment: {
                type: :object,
                additionalProperties: false,
                properties: {
                  multiple_employments: { "$ref": "#/components/schemas/ClientIdArray" },
                },
              },
              employment_tax: {
                type: :object,
                additionalProperties: false,
                properties: {
                  refunds: { "$ref": "#/components/schemas/ClientIdArray" },
                },
              },
              employment_nic: {
                type: :object,
                additionalProperties: false,
                properties: {
                  refunds: { "$ref": "#/components/schemas/ClientIdArray" },
                },
              },
              employment_payment: { "$ref": "#/components/schemas/AmountVariationRemark" },
              state_benefit_payment: { "$ref": "#/components/schemas/AmountVariationRemark" },
              other_income_payment: { "$ref": "#/components/schemas/AmountVariationRemark" },
              outgoings_housing_cost: { "$ref": "#/components/schemas/AmountVariationRemark" },
              outgoings_legal_aid: { "$ref": "#/components/schemas/AmountVariationRemark" },
              outgoings_maintenance: { "$ref": "#/components/schemas/AmountVariationRemark" },
              outgoings_childcare: { "$ref": "#/components/schemas/AmountVariationRemark" },
            },
          },
          OutgoingResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              friends_or_family: { type: :number },
              maintenance_in: { type: :number },
              property_or_lodger: { type: :number },
              pension: { type: :number },
            },
          },
          StateBenefitsResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              monthly_equivalents: {
                type: :object,
                additionalProperties: false,
                required: %i[all_sources cash_transactions bank_transactions],
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
                    items: {
                      type: :object,
                      additionalProperties: false,
                      properties: {
                        name: { type: :string },
                        monthly_value: { type: :number },
                        excluded_from_income_assessment: { type: :boolean },
                      },
                    },
                  },
                },
              },
            },
          },
          OtherIncomeResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              monthly_equivalents: {
                type: :object,
                additionalProperties: false,
                properties: {
                  all_sources: { "$ref": "#/components/schemas/OutgoingResult" },
                  bank_transactions: { "$ref": "#/components/schemas/OutgoingResult" },
                  cash_transactions: { "$ref": "#/components/schemas/OutgoingResult" },
                },
              },
            },
          },
          GrossIncomeResult: {
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
              employment_details: {
                type: :array,
                items: {
                  type: :object,
                  additionalProperties: false,
                  required: %i[monthly_income],
                  properties: {
                    monthly_income: {
                      type: :object,
                      additionalProperties: false,
                      properties: {
                        gross: { type: :number },
                        tax: { type: :number },
                        national_insurance: { type: :number },
                        prisoner_levy: { type: :number },
                        student_debt_repayment: { type: :number },
                        benefits_in_kind: { type: :number },
                        client_id: { type: :string },
                      },
                    },
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
              state_benefits: { "$ref": SCHEMA_COMPONENTS[:state_benefits_result] },
              other_income: { "$ref": SCHEMA_COMPONENTS[:other_income_result] },
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
                        prisoner_levy: {
                          type: :number,
                          format: :decimal,
                          maximum: 0,
                          description: "A negative number representing a Prisoner Levy deduction",
                          example: "-20.00",
                        },
                        student_debt_repayment: {
                          type: :number,
                          format: :decimal,
                          maximum: 0,
                          description: "A negative number representing a Student Debt Repayment deduction",
                          example: "-50.00",
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
          DisposableIncomeResult: {
            type: :object,
            additionalProperties: false,
            properties: {
              monthly_equivalents: {
                type: :object,
                additionalProperties: false,
                properties: {
                  all_sources: {
                    type: :object,
                    additionalProperties: false,
                    properties: {
                      child_care: { type: :number },
                      rent_or_mortgage: { type: :number },
                      maintenance_out: { type: :number },
                      legal_aid: { type: :number },
                      pension_contribution: { type: :number },
                      council_tax: { type: :number },
                      priority_debt_repayment: { type: :number },
                    },
                  },
                  bank_transactions: {
                    type: :object,
                    additionalProperties: false,
                    properties: {
                      child_care: { type: :number },
                      rent_or_mortgage: { type: :number },
                      maintenance_out: { type: :number },
                      legal_aid: { type: :number },
                      pension_contribution: { type: :number },
                      council_tax: { type: :number },
                      priority_debt_repayment: { type: :number },
                    },
                  },
                  cash_transactions: {
                    type: :object,
                    additionalProperties: false,
                    properties: {
                      child_care: { type: :number },
                      rent_or_mortgage: { type: :number },
                      maintenance_out: { type: :number },
                      legal_aid: { type: :number },
                      pension_contribution: { type: :number },
                      council_tax: { type: :number },
                      priority_debt_repayment: { type: :number },
                    },
                  },
                },
              },
              childcare_allowance: { type: :number },
              deductions: {
                type: :object,
                additionalProperties: false,
                properties: {
                  dependants_allowance: { type: :number },
                  disregarded_state_benefits: { type: :number },
                },
              },
            },
          },
          AssessmentCapitalResult: {
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
          v6: {
            Applicant: {
              type: :object,
              description: "Object describing pertinent applicant details",
              required: %i[date_of_birth receives_qualifying_benefit],
              additionalProperties: false,
              properties: {
                date_of_birth: { type: :string,
                                 format: :date,
                                 example: "1992-07-25",
                                 description: "Applicant date of birth" },
                employed: {
                  oneOf: [{ type: :boolean }, { type: :null }],
                  example: true,
                  description: "Deprecated - employment is determined by presence of gross employment income",
                  deprecated: true,
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
                  payments: { "$ref" => "#/components/schemas/v6/EmploymentPaymentList" },
                },
              },
            },
            EmploymentPaymentList: {
              type: :array,
              description: "0 or more employment payment details",
              items: {
                type: :object,
                additionalProperties: false,
                required: %i[client_id date gross benefits_in_kind tax national_insurance],
                properties: {
                  client_id: {
                    type: :string,
                    description: "Client supplied id to identify the payment",
                    example: "05459c0f-a620-4743-9f0c-b3daa93e571",
                  },
                  date: {
                    type: :string,
                    format: :date,
                    example: "1992-07-22",
                  },
                  gross: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack - without it the Swagger web page doesn't display the description and other properties at this level
                    description: "Gross payment income received",
                    example: 101.01,
                  },
                  benefits_in_kind: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:positive_currency] }], # "oneOf" hack
                    description: "Benefit in kind amount received",
                    example: 10.50,
                  },
                  tax: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of tax paid - normally negative, but can be positive for a refund",
                    example: -10.01,
                  },
                  national_insurance: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of national insurance paid - normally negative, but can be positive for a refund",
                    example: -5.24,
                  },
                  prisoner_levy: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of prisoner levy paid - always negative",
                    example: -5.24,
                  },
                  student_debt_repayment: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of student debt repayment paid - always negative",
                    example: -50.00,
                  },
                  net_employment_income: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Deprecated field not used in calculation",
                    deprecated: true,
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
                required: %i[ccms_code],
                properties: {
                  ccms_code: {
                    type: :string,
                    enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                    example: "DA001",
                    description: "A proxy for the type of law. Values beginning with DA are considered domestic abuse cases. IM030 indicates an immigration case. IA031 indicates an asylum case.",
                  },
                  client_involvement_type: {
                    type: :string,
                    enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                    example: "A",
                    description: "A CCMS client_involvement_type. This is not used in the calculation, so can be set to any valid value.",
                    deprecated: true,
                  },
                },
              },
            },
            ProceedingTypeResults: {
              type: :array,
              minItems: 1,
              items: {
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
                  result: { "$ref": "#/components/schemas/OverallResult" },
                },
              },
            },
            ApplicantCapitalResult: {
              type: :object,
              additionalProperties: false,
              properties: {
                total_liquid: { "$ref": "#/components/schemas/TotalLiquidCapital" },
                total_non_liquid: { "$ref": "#/components/schemas/TotalNonLiquidCapital" },
                total_vehicle: { "$ref": "#/components/schemas/TotalVehicleCapital" },
                total_property: { "$ref": "#/components/schemas/TotalPropertyCapital" },
                total_capital: { "$ref": "#/components/schemas/TotalCapital" },
                total_capital_with_smod: { "$ref": "#/components/schemas/TotalCapitalWithSmod" },
                total_mortgage_allowance: { "$ref": "#/components/schemas/TotalMortgageAllowance" },
                subject_matter_of_dispute_disregard: { "$ref": "#/components/schemas/SmodDisregard" },
                assessed_capital: { "$ref": "#/components/schemas/AssessedCapital" },
                disputed_non_property_disregard: { "$ref": "#/components/schemas/DisputedNonPropertyDisregard" },
                pensioner_disregard_applied: { "$ref": "#/components/schemas/PensionerDisregardApplied" },
                proceeding_types: { "$ref": "#/components/schemas/v6/ProceedingTypeResults" },
                pensioner_capital_disregard: { "$ref": "#/components/schemas/PensionerCapitalDisregard" },
                capital_contribution: { "$ref": "#/components/schemas/CapitalContribution" },
                combined_disputed_capital: { "$ref": "#/components/schemas/CombinedDisputedCapital" },
                combined_non_disputed_capital: { "$ref": "#/components/schemas/CombinedNonDisputedCapital" },
                combined_assessed_capital: { "$ref": "#/components/schemas/CombinedAssessedCapital" },
              },
            },
            ApplicantDisposableIncome: {
              type: :object,
              additionalProperties: false,
              properties: {
                employment_income: { "$ref": "#/components/schemas/EmploymentIncomeResult" },
                housing_costs: { "$ref": "#/components/schemas/HousingCosts" },
                gross_housing_costs: {
                  allOf: [
                    { "$ref": "#/components/schemas/HousingCosts" },
                    { deprecated: true },
                  ],
                },
                net_housing_costs: {
                  allOf: [
                    { "$ref": "#/components/schemas/AllowedHousingCosts" },
                    { deprecated: true },
                  ],
                },
                housing_benefit: { "$ref": "#/components/schemas/HousingBenefit" },
                allowed_housing_costs: { "$ref": "#/components/schemas/AllowedHousingCosts" },
                maintenance_allowance: { "$ref": "#/components/schemas/MaintenanceAllowance" },
                dependant_allowance_under_16: { "$ref": "#/components/schemas/DependantAllowanceUnder16" },
                dependant_allowance_over_16: { "$ref": "#/components/schemas/DependantAllowanceOver16" },
                dependant_allowance: { "$ref": "#/components/schemas/DependantAllowance" },
                total_outgoings_and_allowances: { "$ref": "#/components/schemas/TotalOutgoingsAndAllowances" },
                total_disposable_income: { "$ref": "#/components/schemas/TotalDisposableIncome" },
                income_contribution: { "$ref": "#/components/schemas/IncomeContribution" },
                partner_allowance: { "$ref": "#/components/schemas/PartnerAllowance" },
                lone_parent_allowance: { "$ref": "#/components/schemas/LoneParentAllowance" },
                combined_total_outgoings_and_allowances: { "$ref": "#/components/schemas/CombinedOutgoingsAndAllowances" },
                combined_total_disposable_income: { "$ref": "#/components/schemas/CombinedDisposableIncome" },
                proceeding_types: { "$ref": "#/components/schemas/v6/ProceedingTypeResults" },
              },
              required: %i[
                employment_income
                gross_housing_costs
                housing_benefit
                net_housing_costs
                maintenance_allowance
                dependant_allowance_under_16
                dependant_allowance_over_16
                dependant_allowance
                total_outgoings_and_allowances
                total_disposable_income
                income_contribution
                partner_allowance
                lone_parent_allowance
                combined_total_outgoings_and_allowances
                combined_total_disposable_income
                proceeding_types
              ],
            },
            Dependants: {
              type: :array,
              description: "One or more dependants details",
              items: {
                type: :object,
                required: %i[date_of_birth in_full_time_education relationship],
                properties: {
                  date_of_birth: { "$ref": "#/components/schemas/DateOfBirth" },
                  in_full_time_education: { "$ref": "#/components/schemas/InFullTimeEducation" },
                  relationship: { "$ref": "#/components/schemas/RelationShip" },
                  monthly_income: {
                    description: "Dependant's monthly income",
                    # legacy - some currency values are historically allowed as strings
                    deprecated: true,
                    oneOf: [
                      { "$ref" => SCHEMA_COMPONENTS[:numeric_currency] },
                      { "$ref" => SCHEMA_COMPONENTS[:string_currency] },
                    ],
                  },
                  income: { "$ref": "#/components/schemas/DependantIncome" },
                  assets_value: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Dependant's total assets value",
                  },
                },
              },
            },
          },
          v7: {
            Applicant: {
              type: :object,
              description: "Object describing pertinent applicant details",
              required: %i[date_of_birth receives_qualifying_benefit],
              additionalProperties: false,
              properties: {
                date_of_birth: { type: :string,
                                 format: :date,
                                 example: "1992-07-25",
                                 description: "Applicant date of birth" },
                receives_qualifying_benefit: { type: :boolean,
                                               example: false,
                                               description: "Applicant receives qualifying benefit" },
                receives_asylum_support: { type: :boolean,
                                           example: false,
                                           description: "Applicant receives section 4 or section 95 Asylum Support" },
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
                  payments: { "$ref" => "#/components/schemas/v7/EmploymentPaymentList" },
                },
              },
            },
            EmploymentPaymentList: {
              type: :array,
              description: "0 or more employment payment details",
              items: {
                type: :object,
                additionalProperties: false,
                required: %i[client_id date gross benefits_in_kind tax national_insurance],
                properties: {
                  client_id: {
                    type: :string,
                    description: "Client supplied id to identify the payment",
                    example: "05459c0f-a620-4743-9f0c-b3daa93e571",
                  },
                  date: {
                    type: :string,
                    format: :date,
                    example: "1992-07-22",
                  },
                  gross: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack - without it the Swagger web page doesn't display the description and other properties at this level
                    description: "Gross payment income received",
                    example: 101.01,
                  },
                  benefits_in_kind: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:positive_currency] }], # "oneOf" hack
                    description: "Benefit in kind amount received",
                    example: 10.50,
                  },
                  tax: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of tax paid - normally negative, but can be positive for a refund",
                    example: -10.01,
                  },
                  national_insurance: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of national insurance paid - normally negative, but can be positive for a refund",
                    example: -5.24,
                  },
                  prisoner_levy: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of prisoner levy paid - always negative",
                    example: -5.24,
                  },
                  student_debt_repayment: {
                    oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:currency] }], # "oneOf" hack
                    description: "Amount of student debt repayment paid - always negative",
                    example: -50.00,
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
                required: %i[ccms_code],
                properties: {
                  ccms_code: {
                    type: :string,
                    enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                    example: "DA001",
                    description: "A proxy for the type of law. Values beginning with DA are considered domestic abuse cases. IM030 indicates an immigration case. IA031 indicates an asylum case.",
                  },
                },
              },
            },
            ProceedingTypeResults: {
              type: :array,
              minItems: 1,
              items: {
                type: :object,
                required: %i[ccms_code upper_threshold lower_threshold result],
                properties: {
                  ccms_code: {
                    type: :string,
                    enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                    description: "The code expected by CCMS",
                  },
                  upper_threshold: { type: :number },
                  lower_threshold: { type: :number },
                  result: { "$ref": "#/components/schemas/OverallResult" },
                },
              },
            },
            ApplicantCapitalResult: {
              type: :object,
              additionalProperties: false,
              properties: {
                total_liquid: { "$ref": "#/components/schemas/TotalLiquidCapital" },
                total_non_liquid: { "$ref": "#/components/schemas/TotalNonLiquidCapital" },
                total_vehicle: { "$ref": "#/components/schemas/TotalVehicleCapital" },
                total_property: { "$ref": "#/components/schemas/TotalPropertyCapital" },
                total_capital: { "$ref": "#/components/schemas/TotalCapital" },
                total_capital_with_smod: { "$ref": "#/components/schemas/TotalCapitalWithSmod" },
                total_mortgage_allowance: { "$ref": "#/components/schemas/TotalMortgageAllowance" },
                subject_matter_of_dispute_disregard: { "$ref": "#/components/schemas/SmodDisregard" },
                assessed_capital: { "$ref": "#/components/schemas/AssessedCapital" },
                disputed_non_property_disregard: { "$ref": "#/components/schemas/DisputedNonPropertyDisregard" },
                pensioner_disregard_applied: { "$ref": "#/components/schemas/PensionerDisregardApplied" },
                proceeding_types: { "$ref": "#/components/schemas/v7/ProceedingTypeResults" },
                pensioner_capital_disregard: { "$ref": "#/components/schemas/PensionerCapitalDisregard" },
                capital_contribution: { "$ref": "#/components/schemas/CapitalContribution" },
                combined_disputed_capital: { "$ref": "#/components/schemas/CombinedDisputedCapital" },
                combined_non_disputed_capital: { "$ref": "#/components/schemas/CombinedNonDisputedCapital" },
                combined_assessed_capital: { "$ref": "#/components/schemas/CombinedAssessedCapital" },
              },
            },
            ApplicantDisposableIncome: {
              type: :object,
              additionalProperties: false,
              properties: {
                employment_income: { "$ref": "#/components/schemas/EmploymentIncomeResult" },
                housing_costs: { "$ref": "#/components/schemas/HousingCosts" },
                housing_benefit: { "$ref": "#/components/schemas/HousingBenefit" },
                allowed_housing_costs: { "$ref": "#/components/schemas/AllowedHousingCosts" },
                maintenance_allowance: { "$ref": "#/components/schemas/MaintenanceAllowance" },
                dependant_allowance_under_16: { "$ref": "#/components/schemas/DependantAllowanceUnder16" },
                dependant_allowance_over_16: { "$ref": "#/components/schemas/DependantAllowanceOver16" },
                dependant_allowance: { "$ref": "#/components/schemas/DependantAllowance" },
                total_outgoings_and_allowances: { "$ref": "#/components/schemas/TotalOutgoingsAndAllowances" },
                total_disposable_income: { "$ref": "#/components/schemas/TotalDisposableIncome" },
                income_contribution: { "$ref": "#/components/schemas/IncomeContribution" },
                partner_allowance: { "$ref": "#/components/schemas/PartnerAllowance" },
                lone_parent_allowance: { "$ref": "#/components/schemas/LoneParentAllowance" },
                combined_total_outgoings_and_allowances: { "$ref": "#/components/schemas/CombinedOutgoingsAndAllowances" },
                combined_total_disposable_income: { "$ref": "#/components/schemas/CombinedDisposableIncome" },
                proceeding_types: { "$ref": "#/components/schemas/v7/ProceedingTypeResults" },
              },
              required: %i[
                employment_income
                housing_costs
                housing_benefit
                allowed_housing_costs
                maintenance_allowance
                dependant_allowance_under_16
                dependant_allowance_over_16
                dependant_allowance
                total_outgoings_and_allowances
                total_disposable_income
                income_contribution
                partner_allowance
                lone_parent_allowance
                combined_total_outgoings_and_allowances
                combined_total_disposable_income
                proceeding_types
              ],
            },
            Dependants: {
              type: :array,
              description: "One or more dependants details",
              items: {
                type: :object,
                required: %i[date_of_birth in_full_time_education relationship],
                properties: {
                  date_of_birth: { "$ref": "#/components/schemas/DateOfBirth" },
                  in_full_time_education: { "$ref": "#/components/schemas/InFullTimeEducation" },
                  relationship: { "$ref": "#/components/schemas/RelationShip" },
                  income: { "$ref": "#/components/schemas/DependantIncome" },
                  assets_value: {
                    oneOf: [
                      oneOf: [{ "$ref" => SCHEMA_COMPONENTS[:numeric_currency] }], # "oneOf" hack
                      description: "Dependant's total assets value",
                    ],
                    example: 0,
                  },
                },
              },
            },
          },
        },
      },
      paths: {},
    }
  end
end
