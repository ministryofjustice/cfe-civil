And(/^I add the following "([^"]*)" cash_transaction "([^"]*)" details for the partner:$/) do |category, type, table|
  # table is a table.hashes.keys # => [:client_id, :amount, :date]
  @partner_cash_transactions ||= { income: [], outgoings: [] }
  @partner_cash_transactions.merge! type.to_sym => [{ category:, payments: table.hashes.map { cast_values(_1) } }]
end
