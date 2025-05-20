Feature:
    "Applicant is a pensioner, with 3 child and 1 adult dependents.
    They are an applicant in a non-molestation order case, so all upper thresholds don’t apply.
    Applicant does not own property, but does own several valuable items. Pensioner capital disregard is applied.
    Outcome: capital contribution required. "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2019-05-29"
    And A domestic abuse case
    And An Applicant of 61 years old
    And I have a dependant aged 14
    And I have a dependant aged 11
    And I have a dependant aged 9
    And I have a dependant aged 17
    And I add other income "friends_or_family" of 1994.0 per month, with bespoke dates: "2019-04-30" "2019-03-31" "2019-02-28"
    And I add a benefits regular_transactions of 600 every 4 weeks of credit
    And I add multiple outgoing details including "rent_or_mortgage" of 500 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add multiple outgoing details including "child_care" of 25 per month, with bespoke dates: "2019-04-01" "2019-03-01" "2019-02-01"
    And I add 5000 capital of type "bank_accounts"
    And I add 3020 capital of type "non_liquid_capital"
    When I retrieve the final assessment
    Then I should see the following "proceeding_types" details where "ccms_code:DA001":
      | attribute               | value                 |
      | client_involvement_type | A                     |
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
      | attribute               | value    |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |   3000.0              |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 2644.0  |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 8020.0  |
      | total_liquid                | 5000.0  |
      | total_non_liquid            | 3020.0  |
      | total_vehicle               | 0.0     |
      | pensioner_capital_disregard | 0.0     |
      | assessed_capital            | 8020.0  |
      | capital_contribution        | 5020.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 1165.96|
      | total_outgoings_and_allowances | 1665.96|
      | total_disposable_income        | 978.04 |
