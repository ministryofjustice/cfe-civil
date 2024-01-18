And(/^I add the following "([^"]*)" self employment details in the current assessment:$/) do |client_or_partner, table|
  # table is a table.hashes.keys # => [:frequency, :gross_income, :tax, :national_insurance]
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @self_employment_details ||= {}
  @self_employment_details[client_or_partner.to_sym] = table.hashes.map(&:symbolize_keys).map do |h|
    { client_reference: "123", income: h.transform_values { |v| substitute_boolean(v) } }
  end
  # self employment only available in version 6
  @api_version = 6
end

And(/^I add the following "([^"]*)" employment details in the current assessment:$/) do |client_or_partner, table|
  # table is a table.hashes.keys # => [:frequency, :gross_income, :tax, :national_insurance]
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @employment_details ||= {}
  @employment_details[client_or_partner.to_sym] = table.hashes.map(&:symbolize_keys).map do |h|
    { client_reference: "123", income: h.transform_values { |v| substitute_boolean(v) } }
  end
  # employment details only available in version 6
  @api_version = 6
end

Given("The {string} has self employment earnings of {int} per month") do |client_or_partner, income|
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @self_employment_details ||= { client: [], partner: [] }
  @self_employment_details[client_or_partner.to_sym] << {
    client_reference: "123",
    income: {
      frequency: "monthly", gross: income, tax: 0, national_insurance: 0
    },
  }
end

Given("The {string} earns {int} per month") do |client_or_partner, income|
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @employment_details ||= { client: [], partner: [] }
  @employment_details[client_or_partner.to_sym] << {
    client_reference: "123",
    income: {
      frequency: "monthly", gross: income, benefits_in_kind: 0, tax: 0, national_insurance: 0, receiving_only_statutory_sick_or_maternity_pay: false
    },
  }
end

Given("The {string} earns {int} per month in statatory sick pay") do |client_or_partner, income|
  raise ArgumentError, client_or_partner unless client_or_partner.in? %w[client partner]

  @employment_details ||= { client: [], partner: [] }
  @employment_details[client_or_partner.to_sym] << {
    client_reference: "123",
    income: {
      frequency: "monthly", gross: income, benefits_in_kind: 0, tax: 0, national_insurance: 0, receiving_only_statutory_sick_or_maternity_pay: true
    },
  }
end
