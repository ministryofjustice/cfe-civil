module Decorators
  module V5
    class ApplicantDecorator
      def initialize(applicant)
        @record = applicant
      end

      def as_json
        payload unless @record.nil?
      end

    private

      def payload
        {
          date_of_birth: @record.date_of_birth,
          involvement_type: @record.involvement_type,
          employed: @record.employed,
          has_partner_opponent: @record.has_partner_opponent,
          receives_qualifying_benefit: @record.receives_qualifying_benefit,
        }
      end
    end
  end
end
