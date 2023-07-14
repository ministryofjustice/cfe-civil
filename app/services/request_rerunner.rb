class RequestRerunner
  class << self
    API_BASE_URL = "http://localhost:3000/".freeze
    USER_AGENT = "TEST-RERUNNER".freeze
    HEADERS = { "CONTENT_TYPE" => "application/json", "Accept" => "application/json", 'USER-AGENT': USER_AGENT }.freeze
    BATCH_SIZE = 500

    def call
      faraday = Faraday.new(API_BASE_URL, headers: HEADERS) do |f|
        f.request :json
        f.response :json, parser_options: { symbolize_names: true }
        f.response :raise_error
      end

      ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
        count = RequestLog.count
        start = Time.zone.now
        RequestLog.find_in_batches(batch_size: BATCH_SIZE).each_with_index do |batch, index|
          elapsed = Time.zone.now - start
          Rails.logger.info("#{index * BATCH_SIZE}/#{count} requests (#{(elapsed * 1000 / (index * BATCH_SIZE)).to_i} msec/req)") if index.positive?

          # filter out a couple of broken requests that returned success by checking for a sane request size
          batch.reject { |x| x.user_agent == USER_AGENT || x.http_status != 200 || x.request.keys.size < 7 }.each do |v6_request|
            original = remove_problem_keys v6_request.response
            date = original.dig(:assessment, :submission_date)

            faraday_response = faraday.post("/v7/assessments", v6_request.request)
            if faraday_response.success?
              response = remove_problem_keys(faraday_response.body)
              diffs = make_diffs original, response
              # ignore differences where just extra fields have been introduced
              if diffs.any? && !diffs.all? { |d| d[0] == "+" }
                Rails.logger.warn "Differences for date #{date} #{diffs}"
              end
            else
              Rails.logger.error "Response error for #{date} #{faraday_response.body.fetch(:errors)}"
            end
          end
        end
      end

      ActiveRecord::Base.connected_to(role: :writing) do
        RequestLog.find_in_batches(batch_size: BATCH_SIZE).each do |batch|
          RequestLog.transaction do
            batch.select { |x| x.user_agent == USER_AGENT }.each(&:destroy)
          end
        end
      end
    end

  private

    # This appears to be a bugfig - main_home.main_home should always be true, so it's not a valid diff
    OK_DIFFS = [
      ["~", "assessment.capital.capital_items.properties.main_home.main_home", false, true],
      ["~", "assessment.partner_capital.capital_items.properties.main_home.main_home", false, true],
      ["+", "assessment.partner_capital.capital_items.properties.main_home.subject_matter_of_dispute", false],
      ["+", "assessment.capital.capital_items.properties.additional_properties[0].subject_matter_of_dispute", nil],
      ["+", "assessment.capital.capital_items.properties.main_home.subject_matter_of_dispute", nil],
    ].freeze

    # strict: false allows 0.0 and 0 to compare true, and within a small tolerance
    def make_diffs(original, response)
      diffs = Hashdiff.best_diff original, response, strict: false, numeric_tolerance: 0.001
      diffs.reject { |diff| diff.in? OK_DIFFS }
    end

    # remove keys which would mess up the diff (timestamp and application id)
    def remove_problem_keys(resp)
      x = resp.deep_symbolize_keys.except(:timestamp, :version)
      assessment = x.fetch(:assessment)
      applicant = assessment.fetch(:applicant)
      assessment.dig(:gross_income, :employment_income).each do |ei|
        ei.fetch(:payments).sort_by! { |p| [p.fetch(:date), p.fetch(:gross)] }
      end
      assessment.dig(:capital, :capital_items) do |ci|
        ci.fetch(:liquid).sort_by! { |item| item.fetch(:value) }
      end
      # need to ignore DOB as it's not redacted properly (yet) - LEP-281
      x.merge(assessment: assessment.except(:id, :remarks).merge(applicant: applicant.except(:date_of_birth, :involvement_type)))
    end
  end
end
