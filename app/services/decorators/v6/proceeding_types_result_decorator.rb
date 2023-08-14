module Decorators
  module V6
    class ProceedingTypesResultDecorator
      def initialize(eligibilities, proceeding_types)
        @eligibilities = eligibilities
        @proceeding_types = proceeding_types
      end

      def as_json
        @proceeding_types.order(:ccms_code).map { |proceeding_type| pt_result(proceeding_type) }
      end

    private

      def pt_result(proceeding_type)
        elig = @eligibilities.find_by(proceeding_type_code: proceeding_type.ccms_code)
        {
          ccms_code: proceeding_type.ccms_code,
          upper_threshold: elig.upper_threshold.to_f,
          lower_threshold: elig.lower_threshold.to_f,
          result: elig.assessment_result,
        }.tap do |result|
          result[:client_involvement_type] = proceeding_type.client_involvement_type if proceeding_type.client_involvement_type.present?
        end
      end
    end
  end
end
