# frozen_string_literal: true

class AssessmentStats
  def initialize(user_agent:, http_status:)
    @user_agent = user_agent
    @http_status = http_status
  end

  def filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[])
    rows = []
    request_logs.find_each(batch_size: 5000) do |rl|
      response = rl.response.deep_symbolize_keys
      request = rl.request.deep_symbolize_keys
      # filter request
      next unless request[:assessment][:level_of_help] == level_of_help && (request[:applicant][:receives_qualifying_benefit] == passported) && (request[:partner].present? == partner) && rl.http_status == 200

      # filter response
      case reason.sort
      when %i[gross_income].sort
        if match?(response, :gross_income, outcome)
          rows << rl.id
        end
      when %i[disposable_income].sort
        if match?(response, :disposable_income, outcome)
          rows << rl.id
        end
      when %i[capital].sort
        if match?(response, :capital, outcome)
          rows << rl.id
        end
      when %i[gross_income disposable_income].sort
        if match?(response, :gross_income, outcome) && match?(response, :disposable_income, outcome)
          rows << rl.id
        end
      when %i[disposable_income capital].sort
        if match?(response, :disposable_income, outcome) && match?(response, :capital, outcome)
          rows << rl.id
        end
      when %i[gross_income capital].sort
        if match?(response, :gross_income, outcome) && match?(response, :capital, outcome)
          rows << rl.id
        end
      when %i[gross_income disposable_income capital].sort
        if match?(response, :gross_income, outcome) && match?(response, :disposable_income, outcome) && match?(response, :capital, outcome)
          rows << rl.id
        end
      else
        raise "Invalid reason: #{reason} "
      end
    end

    {
      count: rows.size,
      total: request_logs.size,
      percentage: (rows.size * 100).to_f / request_logs.size,
    }
  end

private

  def match?(response, reason, outcome)
    response[:result_summary][reason][:proceeding_types].any? { |pt| pt[:result] == outcome }
  end

  def request_logs
    RequestLog.where(http_status: @http_status).where("user_agent LIKE ?", @user_agent)
  end
end

# assessment_stats = AssessmentStats.new(user_agent: "ccq%(production)", http_status: 200)

# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[disposable_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income capital])

# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[disposable_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income capital])

# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[disposable_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income capital])

# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[disposable_income capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: false, outcome: "ineligible", reason: %i[gross_income disposable_income capital])

# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: false, passported: true, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "controlled", partner: true, passported: true, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: false, passported: true, outcome: "ineligible", reason: %i[capital])
# assessment_stats.filter_eligibility_results(level_of_help: "certificated", partner: true, passported: true, outcome: "ineligible", reason: %i[capital])
