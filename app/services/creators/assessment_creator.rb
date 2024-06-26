module Creators
  class AssessmentCreator
    CreationResult = Struct.new :errors, :assessment, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(remote_ip:, assessment_params:)
        assessment_hash =
          {
            client_reference_id: assessment_params[:client_reference_id],
            submission_date: assessment_params[:submission_date],
            level_of_help: assessment_params[:level_of_help] || Assessment::CERTIFICATED,
            not_aggregated_no_income_low_capital: assessment_params.fetch(:not_aggregated_no_income_low_capital, false),
            controlled_legal_representation: assessment_params.fetch(:controlled_legal_representation, false),
            remote_ip:,
          }

        new_assessment = create_new_assessment_and_summary_records assessment_hash
        if new_assessment.valid?
          CreationResult.new(errors: [], assessment: new_assessment).freeze
        else
          CreationResult.new(errors: new_assessment.errors.full_messages).freeze
        end
      end

    private

      def create_new_assessment_and_summary_records(assessment_hash)
        Assessment.new(assessment_hash)
      end
    end
  end
end
