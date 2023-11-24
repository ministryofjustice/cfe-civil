module Creators
  class FullAssessmentCreator
    class << self
      CreationResult = Struct.new :errors, :assessment, keyword_init: true do
        def success?
          errors.empty?
        end
      end

      def call(remote_ip:, params:)
        result = Creators::AssessmentCreator.call(remote_ip:, assessment_params: params[:assessment])
        if result.success?
          assessment = result.assessment

          errors = CREATE_FUNCTIONS.map { |f|
            f.call(assessment, params)
          }.compact.reject(&:success?).map(&:errors).reduce([], :+)

          CreationResult.new(errors:, assessment: result.assessment.reload).freeze
        else
          result
        end
      end

      CREATE_FUNCTIONS = [
        lambda { |assessment, params|
          Creators::ProceedingTypesCreator.call(assessment:,
                                                proceeding_types_params: { proceeding_types: params[:proceeding_types] })
        },
        lambda { |assessment, params|
          if params[:cash_transactions]
            Creators::CashTransactionsCreator.call(submission_date: assessment.submission_date,
                                                   gross_income_summary: assessment.applicant_gross_income_summary,
                                                   cash_transaction_params: params[:cash_transactions])
          end
        },
        lambda { |assessment, params|
          if params[:irregular_incomes]
            Creators::IrregularIncomeCreator.call(irregular_income_params: params[:irregular_incomes],
                                                  gross_income_summary: assessment.applicant_gross_income_summary)
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
