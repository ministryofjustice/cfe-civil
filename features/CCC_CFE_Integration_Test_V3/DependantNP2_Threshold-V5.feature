Feature:
    "Certificated assessment for an applicant in domestic abuse proceedings.
    The client has 1 child dependants and 1 adult dependants (one of which has income) and post 11th April 2020 rates applied.
    Income from student loan, outgoings for childcare at irregular dates and capital includes a bank account.
    The disposable income and capital is over the lower threshold therefore the result is income and capital contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-04-11"
    And A domestic abuse case
    And I have a dependant aged 13
    And I have a dependant aged 25 with monthly income of 315 and capital 7999
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 12000.00|
    And I add multiple outgoing details including "child_care" of 200 per month, with bespoke dates: "2019-04-15" "2019-04-15" "2019-03-15"
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
      | attribute          | value  |
      | total_gross_income | 1000.0 |
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
      | dependant_allowance            | 307.64 |
      | total_outgoings_and_allowances | 507.64 |
      | total_disposable_income        | 492.36 |
