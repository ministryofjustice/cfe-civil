class SwaggerDocs
  SCHEMA_COMPONENTS = {
    assessment: "#/components/schemas/Assessment",
    applicant: "#/components/schemas/Applicant",
    proceeding_types: "#/components/schemas/ProceedingTypes",
    capitals: "#/components/schemas/Capitals",
    cash_transactions: "#/components/schemas/CashTransactions",
    dependant: "#/components/schemas/Dependant",
    employments: "#/components/schemas/Employments",
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
    property_result: "#/components/schemas/PropertyResult",
    employment_payment_list: "#/components/schemas/EmploymentPaymentList",
    disposable_income: "#/components/schemas/DisposableIncome",
    property: "#/components/schemas/Property",
    proceeding_type_result: "#/components/schemas/ProceedingTypeResult",
    non_property_asset: "#/components/schemas/NonPropertyAsset",
    currency: "#/components/schemas/currency",
    positive_currency: "#/components/schemas/positive_currency",
  }.freeze

  attr_reader :version

  def initialize(version:)
    @version = version
  end

  def api_description
    <<~DESCRIPTION.chomp
      # Check financial eligibility for legal aid.

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
                  description: "Asset detail",
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
                  "$ref" => SCHEMA_COMPONENTS[:currency],
                  description: "Gross payment income received",
                  example: "101.01",
                },
                benefits_in_kind: {
                  "$ref" => SCHEMA_COMPONENTS[:positive_currency],
                  description: "Benefit in kind amount received",
                },
                tax: {
                  "$ref" => SCHEMA_COMPONENTS[:currency],
                  description: "Amount of tax paid - normally negative, but can be positive for a refund",
                  example: -10.01,
                },
                national_insurance: {
                  "$ref" => SCHEMA_COMPONENTS[:currency],
                  description: "Amount of national insurance paid - normally negative, but can be positive for a refund",
                  example: -5.24,
                },
                net_employment_income: {
                  "$ref" => SCHEMA_COMPONENTS[:currency],
                  description: "Deprecated field not used in calculation",
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
                description: "Applicant is employed",
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
          Dependant: {
            type: :object,
            required: %i[date_of_birth in_full_time_education relationship],
            properties: {
              date_of_birth: {
                type: :string,
                format: :date,
                example: "1992-07-27",
              },
              in_full_time_education: {
                type: :boolean,
                example: false,
                description: "Dependant is in full time education or not",
              },
              relationship: {
                type: :string,
                enum: %i[child_relative adult_relative],
                description: "Dependant's relationship to the applicant",
              },
              monthly_income: {
                "$ref" => SCHEMA_COMPONENTS[:currency],
                description: "Dependant's monthly income",
              },
              assets_value: {
                "$ref" => SCHEMA_COMPONENTS[:currency],
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
                        "$ref" => SCHEMA_COMPONENTS[:positive_currency],
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
                  description: "A proxy for the type of law. Values beginning with DA are considered domestic abuse cases. IM030 indicates an immigration case. IA031 indicates an asylum case.",
                },
                client_involvement_type: {
                  type: :string,
                  enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                  example: "A",
                  description: "A CCMS client_involvement_type. This is not used in the calculation, so can be set to any valid value.",
                },
              },
            },
          },
          Property: {
            type: :object,
            required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
            properties: {
              value: {
                "$ref" => SCHEMA_COMPONENTS[:currency],
                description: "Financial value of the property",
              },
              outstanding_mortgage: {
                "$ref" => SCHEMA_COMPONENTS[:currency],
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
              amount: { "$ref" => SCHEMA_COMPONENTS[:currency] },
            },
          },
          SelfEmployment: {
            type: :object,
            required: %i[income],
            additionalProperties: false,
            description: "This should be filled out when the client or partner is self employed",
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
                },
              },
            },
          },
          EmploymentDetails: {
            type: :object,
            required: %i[income],
            additionalProperties: false,
            description: "Details about standard employment",
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
                description: "Name of the state benefit",
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
                      "$ref" => SCHEMA_COMPONENTS[:currency],
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
                "$ref" => SCHEMA_COMPONENTS[:positive_currency],
                description: "Financial value of the vehicle",
              },
              loan_amount_outstanding: {
                "$ref" => SCHEMA_COMPONENTS[:currency],
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
          CapitalResult: {
            type: :object,
            properties: {
              total_liquid: {
                type: :number,
                description: "Total value of all liquid assets in submission",
                format: :decimal,
              },
              total_non_liquid: {
                description: "Total value of all non-liquid assets in submission",
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
              total_capital: {
                description: "Total value of all capital assets in submission",
                type: :number,
                format: :decimal,
              },
              total_mortgage_allowance: {
                description: "Maximum mortgage allowance used in submission. Cases post-April 2020 will all be set to 999_999_999",
                type: :number,
                format: :decimal,
              },
              subject_matter_of_dispute_disregard: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Total amount of subject matter of dispute disregard applied on this submission",
              },
              assessed_capital: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Amount of assessed client capital. Zero if deductions exceed total capital.",
              },
              total_capital_with_smod: {
                type: :number,
              },
              disputed_non_property_disregard: {
                type: :number,
              },
              combined_disputed_capital: {
                type: :number,
              },
              combined_non_disputed_capital: {
                type: :number,
              },
              capital_contribution: {
                type: :number,
                format: :decimal,
              },
              pensioner_capital_disregard: {
                type: :number,
                format: :decimal,
              },
              pensioner_disregard_applied: {
                type: :number,
                format: :decimal,
              },
              combined_assessed_capital: {
                type: :number,
                format: :decimal,
              },
              proceeding_types: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    ccms_code: {
                      type: :string,
                    },
                    client_involvement_type: {
                      type: :string,
                    },
                    upper_threshold: {
                      type: :number,
                      format: :decimal,
                    },
                    lower_threshold: {
                      type: :number,
                      format: :decimal,
                    },
                    result: {
                      type: :string,
                    },
                  },
                },
              },
            },
          },
          DisposableIncome: {
            type: :object,
            properties: {
              employment_income: {
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
              gross_housing_costs: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Calculated monthly rent/mortgage costs",
              },
              housing_benefit: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Calculated monthly housing benefit received",
              },
              net_housing_costs: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Calculated monthly net housing costs (gross - housing_benefit)",
              },
              maintenance_allowance: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Total of maintenance outgoings costs",
              },
              dependant_allowance_under_16: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Allowance for dependants under 16",
              },
              dependant_allowance_over_16: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Allowance for dependants 16 and over",
              },
              dependant_allowance: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Sum of dependant_allowance_under_16 and dependant_allowance_over_16",
              },
              total_outgoings_and_allowances: {
                type: :number,
                format: :decimal,
                description: "Sum of outgoings and allowances",
              },
              total_disposable_income: {
                type: :number,
                format: :decimal,
                description: "Calculated monthly disposable income (gross - outgoings - allowances)",
              },
              income_contribution: {
                type: :number,
                format: :decimal,
                minimum: 0,
                description: "Duplicate of result_summary.income_contribution",
              },
              combined_total_disposable_income: {
                type: :number,
                format: :decimal,
              },
              combined_total_outgoings_and_allowances: {
                type: :number,
                format: :decimal,
              },
              partner_allowance: {
                type: :number,
              },
              proceeding_types: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    ccms_code: {
                      type: :string,
                    },
                    client_involvement_type: {
                      type: :string,
                    },

                    upper_threshold: {
                      type: :number,
                      format: :decimal,
                    },

                    lower_threshold: {
                      type: :number,
                      format: :decimal,
                    },

                    result: {
                      type: :string,
                    },
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