# RequestLog filtering to generate stats based on https://docs.google.com/spreadsheets/d/1YB_JDQJpq_ZqYRbJ-FH53orLgIcuyBplgrDRl8BgY8M/edit#gid=0
class AssessmentStats
  class Statuses
    def initialize(response, outcome)
      @result_summary = response.fetch(:result_summary)
      @outcome = outcome
    end

    def gross_income_match?
      @result_summary.dig(:gross_income, :proceeding_types).any? { |pt| pt[:result] == @outcome }
    end

    def disposable_income_match?
      @result_summary.dig(:disposable_income, :proceeding_types).any? { |pt| pt[:result] == @outcome }
    end

    def capital_match?
      @result_summary.dig(:capital, :proceeding_types).any? { |pt| pt[:result] == @outcome }
    end
  end

  class << self
    def request_log_matched?(request_log:, level_of_help:, partner:, passported:)
      request = request_log.request.deep_symbolize_keys
      request[:assessment][:level_of_help] == level_of_help && (request[:applicant][:receives_qualifying_benefit] == passported) && (request[:partner].present? == partner)
    end

    # filter out the request logs so that they meet the specifiied criteria
    def filter_request_logs(request_logs:, level_of_help:, partner: false, passported: false)
      request_logs.select { |rl| request_log_matched?(request_log: rl, partner:, passported:, level_of_help:) }.map { |rl| rl.response.deep_symbolize_keys }
    end

    def count_gross_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.gross_income_match?
      end
    end

    def count_disposable_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.disposable_income_match?
      end
    end

    def count_capital_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.capital_match?
      end
    end

    def count_gross_disposable_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.gross_income_match? && status.disposable_income_match?
      end
    end

    def count_gross_capital_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.gross_income_match? && status.capital_match?
      end
    end

    def count_disposable_capital_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.disposable_income_match? && status.capital_match?
      end
    end

    def count_gross_disposable_capital_results(responses:, outcome:)
      responses.count do |response|
        status = Statuses.new response, outcome
        status.gross_income_match? && status.disposable_income_match? && status.capital_match?
      end
    end

    def output_counts(row_count:, total_count:)
      {
        count: row_count,
        total: total_count,
        percentage: ((row_count * 100).to_f / total_count).round(2),
      }
    end

    def all_request_logs(user_agent)
      RequestLog.where(http_status: 200).where("user_agent LIKE ?", user_agent).find_each(batch_size: 5000)
    end
  end
end

# request_logs = AssessmentStats.all_request_logs("ccq%(production)")
# responses = AssessmentStats.filter_request_logs(request_logs: request_logs, level_of_help: "controlled", partner: false, passported: false)
# count = AssessmentStats.count_gross_results(responses: responses, outcome: "ineligible")
# AssessmentStats.output_counts(row_count: count, total_count: request_logs.count)
