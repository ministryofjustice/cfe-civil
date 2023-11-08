And(/^I add the following "([^"]*)" other income details for the partner:$/) do |source, table|
  # table is a table.hashes.keys # => [:client_id, :amount, :date]
  @partner_other_incomes ||= []
  @partner_other_incomes << { source:, payments: table.hashes.map { cast_values(_1) } }
end
