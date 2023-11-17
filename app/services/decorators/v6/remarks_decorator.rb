module Decorators
  module V6
    class RemarksDecorator
      def initialize(assessment, remarks, assessment_result)
        @assessment = assessment
        @remarks = remarks
        @assessment_result = assessment_result
      end

      def as_json
        contribution_required? ? transform_remarks : transform_remarks.except!(:policy_disregards)
      end

    private

      def contribution_required?
        @assessment_result.to_s == "contribution_required"
      end

      def transform_remarks
        remarks_hash_by_type = @remarks.group_by(&:type)
        remarks_hash = remarks_hash_by_type.transform_values do |v|
          v.group_by(&:issue).transform_values { |c| c.map(&:ids).flatten }
        end
        remarks_hash.merge! @assessment.explicit_remarks.by_category
        remarks_hash.symbolize_keys
      end
    end
  end
end
