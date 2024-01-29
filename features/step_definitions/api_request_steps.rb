Given("I am undertaking a certificated assessment") do
  StateBenefitType.find_or_create_by! label: "housing_benefit" do |sbt|
    sbt.name = "Housing benefit"
    sbt.exclude_from_gross_income = true
  end
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10" }
  @applicant_data = { date_of_birth: "1979-12-20",
                      involvement_type: "applicant",
                      has_partner_opponent: false,
                      receives_qualifying_benefit: false }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "SE003", client_involvement_type: "A" }] }
  @employments = []
  @api_version = 6
  @capitals_data = {}
  @dependant_data = { dependants: [] }
end

Given("An applicant who receives passporting benefits") do
  @applicant_data.merge! receives_qualifying_benefit: true
end

Given("An applicant who is a pensioner") do
  @applicant_data.merge! date_of_birth: "1939-12-20"
end

Given("An Applicant of {int} years old") do |int|
  date_of_birth = Date.parse(@assessment_data[:submission_date]) - int.years
  @applicant_data.merge! date_of_birth:
end

Given("I add a disputed main property of value {int} and mortgage {int}") do |value, mortgage|
  @main_home = { subject_matter_of_dispute: true, value:, outstanding_mortgage: mortgage, percentage_owned: 100, shared_with_housing_assoc: false }
end

Given("I add a disputed {int} percent share main property of value {int} and mortgage {int}") do |share, value, mortgage|
  @main_home = { subject_matter_of_dispute: true, value:, outstanding_mortgage: mortgage, percentage_owned: share, shared_with_housing_assoc: false }
end

Given("I add a non-disputed main property of value {int}") do |value|
  @main_home = { subject_matter_of_dispute: false, value:, outstanding_mortgage: 0, percentage_owned: 100, shared_with_housing_assoc: false }
end

Given("I add a non-disputed main property of value {int} and mortgage {int}") do |value, mortgage|
  @main_home = { subject_matter_of_dispute: false, value:, outstanding_mortgage: mortgage, percentage_owned: 100, shared_with_housing_assoc: false }
end

Given("I add a non-disputed {int} percent share main property of value {int} and mortgage {int}") do |share, value, mortgage|
  @main_home = { subject_matter_of_dispute: false, value:, outstanding_mortgage: mortgage, percentage_owned: share, shared_with_housing_assoc: false }
end

Given("A submission date of {string}") do |date|
  @assessment_data.merge! submission_date: date
end

#  Pretend MTR starts on Jan 29th 2024 to help apply do their MTR testing
Given("A submission date post-mtr") do
  @assessment_data.merge! submission_date: "2024-01-29"
end

Given("I am undertaking a controlled assessment") do
  StateBenefitType.find_or_create_by! label: "housing_benefit" do |sbt|
    sbt.name = "Housing benefit"
    sbt.exclude_from_gross_income = true
  end
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_help: "controlled" }
  @applicant_data = { date_of_birth: "1989-12-20",
                      involvement_type: "applicant",
                      has_partner_opponent: false,
                      receives_qualifying_benefit: false }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
  @employments = []
  @api_version = 6
  @capitals_data = {}
end

Given("A domestic abuse case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
end

Given("A first tier immigration case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end

Given("A first tier asylum case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end

Given("I have a dependant aged {int}") do |age|
  date_of_birth = Date.parse(@assessment_data[:submission_date]) - age.years
  @dependant_data[:dependants] << { date_of_birth: date_of_birth.to_s, in_full_time_education: true, relationship: "child_relative" }
end

Given("I have a dependant aged {int} with monthly income of {int}") do |age, income|
  date_of_birth = Date.parse(@assessment_data[:submission_date]) - age.years
  @dependant_data[:dependants] << {
    date_of_birth: date_of_birth.to_s,
    in_full_time_education: true,
    monthly_income: income,
    relationship: "child_relative",
  }
end

Given("I have a dependant aged {int} with {string} income of {int}") do |age, frequency, income|
  date_of_birth = Date.parse(@assessment_data[:submission_date]) - age.years
  @dependant_data[:dependants] << {
    date_of_birth: date_of_birth.to_s,
    in_full_time_education: true,
    income: {
      amount: income,
      frequency:,
    },
    relationship: "child_relative",
  }
end

Given("I add housing benefit of {int} per month") do |monthly_housing_benefit|
  dates = %w[2021-07-22 2021-08-22 2021-09-22]
  @benefits_data = {
    state_benefits: [
      { "name": "housing_benefit",
        "payments": dates.map { |date| { client_id: SecureRandom.uuid, amount: monthly_housing_benefit, date: } } },
    ],
  }
end

Given("I add other income {string} of {int} per month") do |income_type, monthly_amount|
  dates = %w[2021-05-10 2021-04-10 2021-03-10]
  payments = dates.map { { date: _1, client_id: SecureRandom.uuid, amount: monthly_amount } }

  @other_incomes_data = { other_incomes: [source: income_type,
                                          payments:] }
end

Given("I add the following irregular_income details in the current assessment:") do |table|
  @irregular_income_data = { "payments": table.hashes.map { cast_values(_1) } }
end

Given("I add outgoing details for {string} of {int} per month") do |outgoing_type, monthly_amount|
  dates = %w[2020-03-10 2020-02-10 2020-01-10]

  the_payments = if outgoing_type == "rent_or_mortgage"
                   dates.map { |d| { payment_date: d, client_id: SecureRandom.uuid, amount: monthly_amount, housing_cost_type: "rent" } }
                 else
                   dates.map { |d| { payment_date: d, client_id: SecureRandom.uuid, amount: monthly_amount } }
                 end

  @outgoings_data = { outgoings: [name: outgoing_type,
                                  payments: the_payments] }
end

Given("I add {int} capital of type {string}") do |amount, capital_type|
  @capitals_data[capital_type.to_sym] ||= []
  @capitals_data[capital_type.to_sym] << { description: "Some Capital", value: amount }
end

Given("I add {int} disputed capital of type {string}") do |amount, capital_type|
  @capitals_data[capital_type.to_sym] ||= []
  @capitals_data[capital_type.to_sym] << { description: "Some Capital", value: amount, subject_matter_of_dispute: true }
end

Given("I add the following employment details:") do |table|
  @employments << { "name": "A",
                    "client_id": "B",
                    "payments": table.hashes.map { cast_values(_1) } }
  @applicant_data.merge! employed: true
end

Given("I add employment income of {int} per month") do |monthly_income|
  @employments << employment_payments_from_income(monthly_income)
end

Given("I add employment income of {int} per month with {int} benefits_in_kind, {int} tax and {int} national insurance") do |monthly_income, benefits, tax, ni|
  @employments << employment_payments_from_income(monthly_income, benefits:, tax:, national_insurance: ni)
end

Given("I add partner employment income of {int} per month") do |monthly_income|
  @partner_employments = [employment_payments_from_income(monthly_income)]
end

Given("I add {string} outgoings of {int} per month") do |name, amount|
  payments = %w[2021-05-10 2021-04-10 2021-03-10].map do |payment_date|
    {
      client_id: "client_id",
      payment_date:,
      amount:,
    }
  end
  @outgoings_data = if name == "rent_or_mortgage"
                      { "outgoings": ["name": name, "payments": payments.map { _1.merge(housing_cost_type: "rent") }] }
                    else
                      { "outgoings": ["name": name, "payments": payments] }
                    end
end

Given("I add {string} cash_transactions of {int} per month") do |category, amount|
  submission_date = Date.parse(@assessment_data[:submission_date])
  payments = (1..3).map do |i|
    {
      client_id: "client_id",
      date: (submission_date - i.months).beginning_of_month,
      amount:,
    }
  end
  @cash_transactions = { "cash_transactions": { "outgoings": ["category": category, "payments": payments], "income": [] } }
end

Given("I add {string} regular_transactions of {int} per month") do |category, amount|
  @regular_transactions = [{
    category:,
    frequency: "monthly",
    operation: "debit",
    amount:,
  }]
end

Given("I add {string} partner regular_transactions of {int} per month") do |category, amount|
  @partner_regular_transactions = [{
    category:,
    frequency: "monthly",
    operation: "debit",
    amount:,
  }]
end

Given("I add the following additional property details for the partner in the current assessment:") do |table|
  @partner_property = [cast_values(table.rows_hash)]
end

Given("I add the following additional property details for the current assessment:") do |table|
  @secondary_home = cast_values(table.rows_hash)
end

Given("I add the following proceeding types in the current assessment:") do |table|
  @proceeding_type_data = { "proceeding_types": table.hashes.map { cast_values(_1) } }
end

Given("I add the following vehicle details for the current assessment:") do |table|
  @vehicle_data = { "vehicles": [cast_values(table.rows_hash)] }
end

Given("I add the following capital details for {string} for the partner:") do |string, table|
  @partner_capitals = { string.to_s => table.hashes.map { cast_values(_1) } }
end

When("I retrieve the final assessment") do
  if @main_home || @secondary_home
    additional_properties = @secondary_home ? [@secondary_home] : []
    main_home = @main_home || blank_main_home
    main_home_data = { "properties": { main_home:, additional_properties: } }
  end

  if @employments
    employments_data = { employment_income: @employments }
  end

  self_employed_partner = @self_employment_details && @self_employment_details.key?(:partner)
  employed_partner = @employment_details && @employment_details.key?(:partner)

  if @partner_employments || @partner_property ||
      @partner_regular_transactions || @partner_capitals ||
      @partner_cash_transactions || @partner_other_incomes ||
      self_employed_partner || employed_partner
    employments = @partner_employments || []
    additional_properties = @partner_property || []
    regular_transactions = @partner_regular_transactions || []
    capitals = @partner_capitals || {}
    partner_data = { partner: { "date_of_birth": "1992-07-22", "employed": false },
                     additional_properties:,
                     regular_transactions:,
                     capitals: }
    partner_data[:cash_transactions] = @partner_cash_transactions if @partner_cash_transactions
    partner_data[:other_incomes] = @partner_other_incomes if @partner_other_incomes
    if employments.any?
      partner_data[:employments] = employments
      partner_data[:partner] = partner_data.fetch(:partner).merge(employed: true)
    end
  end

  single_shot_api_data = { assessment: @assessment_data,
                           applicant: @applicant_data }.merge(@proceeding_type_data)
  single_shot_api_data.merge!(@dependant_data) if @dependant_data
  single_shot_api_data.merge!(employments_data) if employments_data
  single_shot_api_data.merge!(@other_incomes_data) if @other_incomes_data
  single_shot_api_data[:irregular_incomes] = @irregular_income_data if @irregular_income_data
  single_shot_api_data.merge!(@benefits_data) if @benefits_data

  single_shot_api_data.merge!(@outgoings_data) if @outgoings_data
  single_shot_api_data.merge!(@cash_transactions) if @cash_transactions

  single_shot_api_data.merge!(main_home_data) if main_home_data
  single_shot_api_data.merge!(@vehicle_data) if @vehicle_data
  single_shot_api_data[:capitals] = @capitals_data if @capitals_data && @capitals_data.any?
  single_shot_api_data[:regular_transactions] = @regular_transactions if @regular_transactions

  partner_data[:self_employment_details] = @self_employment_details[:partner] if self_employed_partner
  partner_data[:employment_details] = @employment_details[:partner] if employed_partner
  single_shot_api_data[:partner] = partner_data if partner_data
  single_shot_api_data[:self_employment_details] = @self_employment_details[:client] if @self_employment_details && @self_employment_details.key?(:client)
  single_shot_api_data[:employment_details] = @employment_details[:client] if @employment_details && @employment_details.key?(:client)

  travel_to @assessment_data.fetch(:submission_date) do
    @single_shot_response = submit_post_request "/v6/assessments", single_shot_api_data
  end
end

Then("I should see the following overall summary:") do |table|
  failures = []
  table.hashes.each do |row|
    result = extract_response_section(@single_shot_response, @api_version, row["attribute"])
    error = validate_response(result, row["value"], row["attribute"])

    failures.append(error) if error.present?
  end

  unless failures.empty?
    failures.append "\n----\Response being validated: #{@response.to_json}\n----\n"
  end

  raise_if_present(failures)
end

# To be used where the response has an array and you're asserting a block within it based on a conditional value within.
Then("I should see the following {string} details where {string}:") do |attribute, condition, table|
  response_section = extract_response_section @single_shot_response, @api_version, attribute

  param, value = condition.split(":")

  selected_item = response_section.find { |item| item[param] == value }

  if selected_item.nil?
    raise "Unable to find section in response based on condition '#{condition}' for attribute '#{attribute}'. Found: #{response_section}"
  end

  failures = []
  table.hashes.each do |row|
    error = validate_response(selected_item[row["attribute"]], row["value"], attribute, condition:)

    failures.append(error) if error
  end

  unless failures.empty?
    failures.append "\n----\nSelected response being validated: #{selected_item.to_json}\n----\n"
  end

  raise_if_present(failures)
end

Then("I should see the following {string} details:") do |section_name, table|
  response_section = extract_response_section(@single_shot_response, @api_version, section_name)

  failures = []
  table.hashes.each do |row|
    error = validate_response(response_section[row["attribute"]], row["value"], row["attribute"])
    failures.append(error) if error.present?
  end

  if failures.any?
    failures.append "\n----\nSelected response being validated: #{response_section.to_json}\n----\n"
  end

  raise_if_present(failures)
end

Then("I should see the following {string} details for the partner:") do |section_name, table|
  response_section = extract_response_section(@single_shot_response, @api_version, section_name)

  failures = []
  table.hashes.each do |row|
    error = validate_response(response_section[row["attribute"]], row["value"], row["attribute"])
    failures.append(error) if error.present?
  end
  if failures.any?
    failures.append "\n----\nSelected response being validated: #{response_section.to_json}\n----\n"
  end

  raise_if_present(failures)
end
