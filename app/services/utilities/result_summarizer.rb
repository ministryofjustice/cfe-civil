module Utilities
  # calculate the overall given an array of results (from the eligibility records for each proceeding type)
  class ResultSummarizer
    class << self
      def call(individual_results)
        if individual_results.empty?
          :not_calculated
        else
          summarized_results(individual_results.uniq.map(&:to_sym))
        end
      end

    private

      def summarized_results(uniq_results)
        if uniq_results.include?(:not_calculated)
          :not_calculated
        elsif uniq_results.include?(:not_yet_known)
          :not_yet_known
        elsif uniq_results == [:eligible]
          :eligible
        elsif uniq_results == [:ineligible]
          :ineligible
        elsif !uniq_results.include?(:ineligible)
          :contribution_required
        else
          :partially_eligible
        end
      end
    end
  end
end
