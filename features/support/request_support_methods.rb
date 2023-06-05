def submit_post_request(path, payload)
  headers = { "CONTENT_TYPE" => "application/json", "Accept" => "application/json" }
  page.driver.post(path, payload.to_json, headers)
  result = JSON.parse(page.body)
  raise(result["errors"]&.join("\n")) unless result["success"]

  result
end

def cast_values(payload)
  payload.map { |pair| [pair[0], substitute_boolean(pair[1])] }.to_h
end

def integer_or_float?(value)
  !Float(value).nil?
rescue ArgumentError
  false
end

def substitute_boolean(value)
  return true if value&.casecmp("true")&.zero?
  return false if value&.casecmp("false")&.zero?

  if integer_or_float?(value)
    value.to_f
  else
    value
  end
end

def blank_main_home
  {
    value: 0,
    outstanding_mortgage: 0,
    percentage_owned: 0,
    shared_with_housing_assoc: false,
    subject_matter_of_dispute: false,
  }
end
