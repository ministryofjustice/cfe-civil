Then(/^I should see the following remarks indicating caseworker referral$/) do |table|
  response_section = extract_response_section @single_shot_response, @api_version, "remarks"
  actual_result = response_section.map { |k, v| { type: k, issue: v.keys.first } }

  expected_result = table.hashes.map(&:symbolize_keys)

  act_exp_diffs = actual_result.difference(expected_result)
  exp_act_diffs = expected_result.difference(actual_result)

  diffs = exp_act_diffs.zip(act_exp_diffs).map do |expected, actual|
    value_mismatch("remarks", expected, actual)
  end

  raise_if_present(diffs)
end
