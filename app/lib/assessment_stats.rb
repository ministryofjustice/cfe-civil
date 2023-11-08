# frozen_string_literal: true

class AssessmentStats
  class << self
    def call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income], user_agent: "ccq%(production)")
      eligibility_results(level_of_help:, outcome:, reason:, partner:, passported:, user_agent:)
    end

  private

    def eligibility_results(level_of_help:, outcome:, reason:, partner:, passported:, user_agent:)
      rows = []
      request_logs = RequestLog.where(http_status: 200).where("user_agent LIKE ?", user_agent)
      request_logs.each do |rl|
        response = rl.response.deep_symbolize_keys
        request = rl.request.deep_symbolize_keys
        # filter request
        if request[:assessment][:level_of_help] == level_of_help && (request[:applicant][:receives_qualifying_benefit] == passported) && (request[:partner].present? == partner) && rl.http_status == 200
          # filter response
          if reason.all? "gross_income"
            if response[:result_summary][:gross_income][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.all? "disposable_income"
            if response[:result_summary][:disposable_income][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.all? "capital"
            if response[:result_summary][:capital][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.any?("gross_income") && reason.any?("disposable_income") && reason.any?("capital")
            if response[:result_summary][:gross_income][:proceeding_types].any? { |pt| pt[:result] == outcome } && response[:result_summary][:disposable_income][:proceeding_types].any? { |pt| pt[:result] == outcome } && response[:result_summary][:capital][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.any?("gross_income") && reason.any?("disposable_income")
            if response[:result_summary][:gross_income][:proceeding_types].any? { |pt| pt[:result] == outcome } && response[:result_summary][:disposable_income][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.any?("disposable_income") && reason.any?("capital")
            if response[:result_summary][:disposable_income][:proceeding_types].any? { |pt| pt[:result] == outcome } && response[:result_summary][:capital][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          elsif reason.any?("gross_income") && reason.any?("capital")
            if response[:result_summary][:gross_income][:proceeding_types].any? { |pt| pt[:result] == outcome } && response[:result_summary][:capital][:proceeding_types].any? { |pt| pt[:result] == outcome }
              rows << rl.id
            end
          end
        end
      end
      {
        count: rows.size,
        total: request_logs.size,
        percentage: (rows.size * 100).to_f / request_logs.size,
      }
    end
  end
end

# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[disposable_income])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income capital])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[disposable_income capital])
# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income capital])

# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[disposable_income])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income capital])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[disposable_income capital])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income capital])

# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[disposable_income])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income capital])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[disposable_income capital])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income capital])

# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[disposable_income])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income capital])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[disposable_income capital])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %w[gross_income disposable_income capital])

# AssessmentStats.call(level_of_help: "controlled", partner: false, passported: true, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "controlled", partner: true, passported: true, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "certificated", partner: false, passported: true, outcome: "ineligible", reason: %w[capital])
# AssessmentStats.call(level_of_help: "certificated", partner: true, passported: true, outcome: "ineligible", reason: %w[capital])
