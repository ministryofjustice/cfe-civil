Feature:
    "Certificated assessment for an applicant in domestic abuse proceedings.
    The client has 1 child dependant and post 6th April 2020 rates applied.
    Income from friends/family, outgoings for childcare but this is not included as there is no employment income and capital includes a bank account.
    The capital is over the lower threshold therefore the result is capital contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2020-04-21"
    And A domestic abuse case
    And I have a dependant aged 12
    And I add other income "friends_or_family" of 100 per month, with bespoke dates: "2019-04-15" "2019-03-15" "2019-02-15"
    And I add "child_care" outgoings of ["200 200"]; with bespoke dates ["2020-03-27 2020-02-29"]
    And I add 3002 capital of type "bank_accounts"
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
      | total_gross_income | 100.0    |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 3002.0  |
      | total_liquid                | 3002.0  |
      | total_non_liquid            | 0.0     |
      | total_vehicle               | 0.0     |
      | pensioner_capital_disregard | 0.0     |
      | assessed_capital            | 3002.0  |
      | capital_contribution        | 2.0     |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 296.65 |
      | total_outgoings_and_allowances | 296.65 |
      | total_disposable_income        | -196.65|
