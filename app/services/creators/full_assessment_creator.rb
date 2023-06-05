module Creators
  class FullAssessmentCreator
    class << self
      CreationResult = Struct.new :errors, :assessment, keyword_init: true do
        def success?
          errors.empty?
        end
      end

      def call(remote_ip:, params:)
        create = Creators::AssessmentCreator.call(remote_ip:,
                                                  assessment_params: params[:assessment],
                                                  version: CFEConstants::DEFAULT_ASSESSMENT_VERSION)
        assessment = create.assessment

        errors = CREATE_FUNCTIONS.map { |f|
          f.call(assessment, params)
        }.compact.reject(&:success?).map(&:errors).reduce([], :+)

        CreationResult.new(errors:, assessment: create.assessment.reload).freeze
      end

      CREATE_FUNCTIONS = [
        lambda { |assessment, params|
          Creators::ProceedingTypesCreator.call(assessment:,
                                                proceeding_types_params: { proceeding_types: params[:proceeding_types] })
        },
        lambda { |assessment, params|
          Creators::ApplicantCreator.call(assessment:,
                                          applicant_params: { applicant: params[:applicant] })
        },
        lambda { |assessment, params|
          if params[:cash_transactions]
            Creators::CashTransactionsCreator.call(submission_date: assessment.submission_date,
                                                   gross_income_summary: assessment.applicant_gross_income_summary,
                                                   cash_transaction_params: params[:cash_transactions])
          end
        },
        lambda { |assessment, params|
          if params[:employment_income]
            Creators::EmploymentsCreator.call(employment_collection: assessment.employments,
                                              employments_params: { employment_income: params[:employment_income] })
          end
        },
        lambda { |assessment, params|
          if params[:irregular_incomes]
            Creators::IrregularIncomeCreator.call(irregular_income_params: params[:irregular_incomes],
                                                  gross_income_summary: assessment.applicant_gross_income_summary)
          end
        },
        lambda { |assessment, params|
          if params[:other_incomes]
            Creators::OtherIncomesCreator.call(gross_income_summary: assessment.applicant_gross_income_summary,
                                               other_incomes_params: { other_incomes: params[:other_incomes] })
          end
        },
        lambda { |assessment, params|
          if params[:state_benefits]
            Creators::StateBenefitsCreator.call(gross_income_summary: assessment.applicant_gross_income_summary,
                                                state_benefits_params: { state_benefits: params[:state_benefits] })
          end
        },
        lambda { |assessment, params|
          if params[:capitals]
            Creators::CapitalsCreator.call(capital_params: params[:capitals],
                                           capital_summary: assessment.applicant_capital_summary)
          end
        },
        lambda { |assessment, params|
          if params[:regular_transactions]
            Creators::RegularTransactionsCreator.call(
              gross_income_summary: assessment.applicant_gross_income_summary,
              regular_transaction_params: { regular_transactions: params[:regular_transactions] },
            )
          end
        },
        lambda { |assessment, params|
          if params[:outgoings]
            Creators::OutgoingsCreator.call(disposable_income_summary: assessment.applicant_disposable_income_summary,
                                            outgoings_params: { outgoings: params[:outgoings] })
          end
        },
        lambda { |assessment, params|
          if params[:properties]
            Creators::PropertiesCreator.call(capital_summary: assessment.applicant_capital_summary,
                                             properties_params: { properties: params[:properties] })
          end
        },
        lambda { |assessment, params|
          if params[:partner]
            Creators::PartnerFinancialsCreator.call(assessment:,
                                                    partner_financials_params: params[:partner])
          end
        },
        lambda { |assessment, params|
          if params[:explicit_remarks]
            Creators::ExplicitRemarksCreator.call(assessment:,
                                                  explicit_remarks_params: { explicit_remarks: params[:explicit_remarks] })
          end
        },
      ].freeze
    end
  end
end
