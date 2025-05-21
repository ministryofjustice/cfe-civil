Feature:
    "Certificated assessment for an applicant in domestic abuse proceedings.
    The client is over 60. Income from student loan and capital includes a bank account which is reduced by pensioner disregard calculated on the disposable income.
    The capital is over the lower threshold therefore the result is capital contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-10"
    And A domestic abuse case
    And An Applicant of 78 years old
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 1200    |
    And I add 75003 capital of type "bank_accounts"
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
      | total_gross_income | 100.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 75003.0 |
      | total_liquid                | 75003.0 |
      | total_non_liquid            | 0.0     |
      | total_vehicle               | 0.0     |
      | pensioner_capital_disregard | 70000.0 |
      | assessed_capital            | 5003.0  |
      | capital_contribution        | 2003.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 0      |
      | total_outgoings_and_allowances | 0.0    |
      | total_disposable_income        | 100.0  |
