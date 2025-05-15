Feature:
    "Applicant is a single person, with no dependents.
    They are an applicant in a non-molestation order case, so all upper thresholds don’t apply.
    They do not own property, but do have some valuable assets. Outcome: income and capital contribution required. "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2019-05-29"
    And A domestic abuse case
    And I add other income "friends_or_family" of 1278.01 per month, with bespoke dates: "2019-04-30" "2019-03-31" "2019-02-28"
    And I add multiple outgoing details including "rent_or_mortgage" of 700 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add 5000 capital of type "bank_accounts"
    And I add 3000 capital of type "non_liquid_capital"
    When I retrieve the final assessment
    Then I should see the following "proceeding_types" details where "ccms_code:DA001":
      | attribute               |              value    |
      | client_involvement_type |              A        |
      | result                  | contribution_required |
    And I should see the following "gross_income_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "disposable_income_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | lower_threshold  | 315.0           |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "capital_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | lower_threshold  | 3000.0          |
      | upper_threshold  | 999999999999.0  |
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 1278.01 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 8000.0  |
      | total_liquid                | 5000.0  |
      | total_non_liquid            | 3000.0  |
      | total_vehicle               | 0.0     |
      | pensioner_capital_disregard | 0.0     |
      | assessed_capital            |   8000.0|
      | capital_contribution        |   5000.0|
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 0      |
      | total_outgoings_and_allowances | 545.0  |
      | total_disposable_income        | 733.01 |
