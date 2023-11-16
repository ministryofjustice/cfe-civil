module Decorators
  module V6
    class RemarksDecorator
      def initialize(record, assessment_result)
        @record = record
        @assessment_result = assessment_result
      end

      def as_json
        contribution_required? ? @record : @record.except!(:policy_disregards)
      end

    private

      def contribution_required?
        @assessment_result.to_s == "contribution_required"
      end
    end
  end
end
