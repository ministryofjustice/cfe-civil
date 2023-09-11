module Decorators
  module V6
    class ProceedingTypesResultDecorator
      def initialize(results)
        @results = results
      end

      def as_json
        @results.sort_by { |r| r.proceeding_type.ccms_code }.map { |elig| pt_result(elig) }
      end

    private

      def pt_result(result)
        {
          ccms_code: result.proceeding_type.ccms_code,
          upper_threshold: result.eligibility.upper_threshold.to_f,
          lower_threshold: result.eligibility.lower_threshold.to_f,
          result: result.eligibility.assessment_result,
        }.tap do |hash|
          hash[:client_involvement_type] = result.proceeding_type.client_involvement_type if result.proceeding_type.client_involvement_type.present?
        end
      end
    end
  end
end
