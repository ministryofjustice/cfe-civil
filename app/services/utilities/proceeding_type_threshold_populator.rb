module Utilities
  class ProceedingTypeThresholdPopulator
    class << self
      def certificated(proceeding_types:, submission_date:)
        waiver_data = retrieve_waiver_data(proceeding_types)
        proceeding_types.each do |proceeding_type|
          waivers = waiver_data.fetch(proceeding_type.ccms_code, {})
          proceeding_type.update!(
            gross_income_upper_threshold: determine_threshold_for(:gross_income_upper, waivers[:gross_income_upper], submission_date),
            disposable_income_upper_threshold: determine_threshold_for(:disposable_income_upper, waivers[:disposable_income_upper], submission_date),
            capital_upper_threshold: determine_threshold_for(:capital_upper, waivers[:capital_upper], submission_date),
          )
        end
      end

      def controlled(proceeding_types:, submission_date:)
        proceeding_types.each do |proceeding_type|
          proceeding_type.update!(
            gross_income_upper_threshold: standard_value(:gross_income_upper, submission_date),
            disposable_income_upper_threshold: standard_value(:disposable_income_upper, submission_date),
            capital_upper_threshold: standard_value(:capital_upper, submission_date),
          )
        end
      end

    private

      def retrieve_waiver_data(proceeding_types)
        if waivers_may_apply?(proceeding_types)
          LegalFrameworkAPI::ThresholdWaivers.call(proceeding_type_details(proceeding_types)).fetch(:proceedings).index_by { _1.fetch(:ccms_code) }
        else
          {}
        end
      end

      def proceeding_type_details(proceeding_types)
        proceeding_types.order(:ccms_code).map do |pt|
          { ccms_code: pt.ccms_code, client_involvement_type: pt.client_involvement_type }
        end
      end

      # returns threshold of a particular type:
      # params:
      # * threshold_type: :gross_income_upper, :disposable_income_upper or :capital_upper
      # * waived: true, false or nil (where nil is equivalent to false)
      #
      def determine_threshold_for(threshold_type, waived, submission_date)
        waived ? waived_value(submission_date) : standard_value(threshold_type, submission_date)
      end

      def standard_value(threshold_type, submission_date)
        Threshold.value_for(threshold_type, at: submission_date)
      end

      def waived_value(submission_date)
        Threshold.value_for(:infinite_gross_income_upper, at: submission_date)
      end

      def waivers_may_apply?(proceeding_types)
        proceeding_types.none? do |type|
          type.ccms_code.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES.map(&:to_s))
        end
      end
    end
  end
end
