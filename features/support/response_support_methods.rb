RESPONSE_SECTION_MAPPINGS = {
  "v6" => {
    "assessment_result" => "result_summary.overall_result.result",
    "capital contribution" => "result_summary.overall_result.capital_contribution",
    "income contribution" => "result_summary.overall_result.income_contribution",
    "disposable_income_summary" => "result_summary.disposable_income",
    "disposable income" => "assessment.disposable_income",
    "gross income" => "result_summary.gross_income",
    "disposable_income_all_sources" => "assessment.disposable_income.monthly_equivalents.all_sources",
    "disposable_income_bank_transactions" => "assessment.disposable_income.monthly_equivalents.bank_transactions",
    "disposable_income_cash_transactions" => "assessment.disposable_income.monthly_equivalents.cash_transactions",
    "partner_disposable_income_all_sources" => "assessment.partner_disposable_income.monthly_equivalents.all_sources",
    "partner_other_income_all_sources" => "assessment.partner_gross_income.other_income.monthly_equivalents.all_sources",
    "total outgoings and allowances" => "result_summary.disposable_income.combined_total_outgoings_and_allowances",
    "partner allowance" => "result_summary.disposable_income.partner_allowance",
    "dependant allowance" => "result_summary.disposable_income.dependant_allowance",
    "dependant allowance under 16" => "result_summary.disposable_income.dependant_allowance_under_16",
    "dependant allowance over 16" => "result_summary.disposable_income.dependant_allowance_over_16",
    "net housing costs" => "result_summary.disposable_income.net_housing_costs",
    "gross housing costs" => "result_summary.disposable_income.gross_housing_costs",
    "capital summary" => "result_summary.capital",
    "partner capital summary" => "result_summary.partner_capital",
    "capital_lower_threshold" => "result_summary.capital.proceeding_types.0.lower_threshold",
    "capital_upper_threshold" => "result_summary.capital.proceeding_types.0.upper_threshold",
    "disposable_lower_threshold" => "result_summary.disposable_income.proceeding_types.0.lower_threshold",
    "disposable_upper_threshold" => "result_summary.disposable_income.proceeding_types.0.upper_threshold",
    "gross_income_upper_threshold_0" => "result_summary.gross_income.proceeding_types.0.upper_threshold",
    "gross_income_upper_threshold_1" => "result_summary.gross_income.proceeding_types.1.upper_threshold",
    "gross_income_lower_threshold_0" => "result_summary.gross_income.proceeding_types.0.lower_threshold",
    "gross_income_lower_threshold_1" => "result_summary.gross_income.proceeding_types.1.lower_threshold",
    "gross_income_proceeding_types" => "result_summary.gross_income.proceeding_types",
    "disposable_income_proceeding_types" => "result_summary.disposable_income.proceeding_types",
    "capital_proceeding_types" => "result_summary.capital.proceeding_types",
    "main property" => "assessment.capital.capital_items.properties.main_home",
    "additional property" => "assessment.capital.capital_items.properties.additional_properties.0",
    "vehicle" => "assessment.capital.capital_items.vehicles.0",
    "partner property" => "assessment.partner_capital.capital_items.properties.additional_properties.0",
    "overall_disposable_income" => "result_summary.partner_disposable_income",
    "employment" => "result_summary.disposable_income.employment_income",
    "partner_employment" => "result_summary.partner_disposable_income.employment_income",
    "combined_assessed_capital" => "result_summary.capital.combined_assessed_capital",
    "remarks" => "assessment.remarks",
    "proceeding_types" => "result_summary.overall_result.proceeding_types",
  },
}.freeze

def response_section_for(version, attribute)
  unless RESPONSE_SECTION_MAPPINGS.key?("v#{version}")
    raise "Provided version '#{version}' does not have any mapping defined."
  end

  api_mapping = RESPONSE_SECTION_MAPPINGS["v#{version}"]

  unless api_mapping.key?(attribute)
    raise "Provided attribute '#{attribute}' was not found in mapping for version '#{version}'. Available attributes are: #{api_mapping.map { |k, v| "#{k} => #{v}" }}"
  end

  api_mapping[attribute]
end

def section_from_path(relevant_section, section_path, section_name)
  section_path.split(".").each do |key|
    key = key.to_i if relevant_section.is_a?(Array)

    if relevant_section[key].nil?
      raise "Expected to have key '#{key}' in '#{relevant_section}' using attribute '#{section_name}' with path '#{section_path}'"
    end

    relevant_section = relevant_section[key]
  end

  relevant_section
end

# Fetch the json values from within the response based on the mapping defined for the section
def extract_response_section(single_shot_response, version, section_name)
  section_path = response_section_for(version, section_name)

  section_from_path(single_shot_response, section_path, section_name)
end

def raise_if_present(failures)
  raise failures.join("\n") if failures.any?
end

def validate_response(result, value, attribute, condition: nil)
  return if value.to_s == result.to_s

  value_mismatch attribute, value, result, condition:
end

def value_mismatch(attribute, expected, actual, condition: nil)
  condition_clause = " with condition: #{condition}" if condition

  "\n==> [#{attribute}] Value mismatch. Expected (++), Actual (--): \n++ #{expected}\n-- #{actual}\n\nfor attribute #{attribute}#{condition_clause}."
end
