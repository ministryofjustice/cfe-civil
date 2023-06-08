class RedactClientIDService
  def self.call
    new.call
  end

  def call
    # get all requests and id from request_log rows
    log_items = RequestLog.pluck("id", "request")
    # update client_id's for the request column in each row
    log_items.each do |li|
      rid = li[0] # get id so we can save the record once updated
      cts = li[1]
      cts = cts["cash_transactions"]
      cts_income = cts["income"]
      cts_outgoings = cts["outgoings"]

      # update client_id for income payments (all categories)
      cts_income.each do |ci|
        payments = ci["payments"]
        payments.each do |p|
          p["client_id"] = CFEConstants::REDACTED_MESSAGE
        end
      end

      # update the client_id for outgoing payments (all categories)
      cts_outgoings.each do |co|
        payments = co["payments"]
        payments.each do |p|
          p["client_id"] = CFEConstants::REDACTED_MESSAGE
        end
      end
      # persist the change
      req = RequestLog.where(id: rid).first
      req.update! request: li
    end
  end
end
