module Creators
  class ApplicantCreator
    Result = Struct.new :errors, :applicant, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, applicant_params:)
        applicant = create_applicant(assessment:, applicant_params:)
        Result.new(errors: [], applicant:).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

    private

      def create_applicant(assessment:, applicant_params:)
        Applicant.create!(applicant_params[:applicant].merge(assessment:))
      end
    end
  end
end
