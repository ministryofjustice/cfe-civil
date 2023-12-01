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
                                                proceeding_types_params: { proceeding_types: params.fetch(:proceeding_types, []) })
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
