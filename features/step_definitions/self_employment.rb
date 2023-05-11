And(/^I add the following "([^"]*)" self employment details in the current assessment:$/) do |client_or_partner, table|
  # table is a table.hashes.keys # => [:frequency, :gross_income, :tax, :national_insurance]
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @self_employment_data ||= {}
  @self_employment_data[client_or_partner.to_sym] = table.hashes.map(&:symbolize_keys).map do |h|
    # { income: h.merge(is_employment: substitute_boolean(h.fetch(:is_employment))) }
    { client_reference: "123", income: h.transform_values { |v| substitute_boolean(v) } }
  end
  # self employment only available in version 6
  @api_version = 6
end
