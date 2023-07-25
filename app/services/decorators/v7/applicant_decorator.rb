module Decorators
  module V7
    class ApplicantDecorator
      def initialize(applicant)
        @record = applicant
      end

      def as_json
        {
          date_of_birth: @record.date_of_birth,
          has_partner_opponent: @record.has_partner_opponent,
          receives_qualifying_benefit: @record.receives_qualifying_benefit,
        }
      end
    end
  end
end
