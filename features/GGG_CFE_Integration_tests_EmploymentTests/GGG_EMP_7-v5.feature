Feature:
  " 1. Eligible
    2. Income contribution
    3. Employed - monthly "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2020-07-27"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 1
    And I add employment income of 1115.15 per month with 0.0 benefits_in_kind, 1.40 tax and 38.78 national insurance
    And I add other income "friends_or_family" of 500 per month
    And I add outgoing details for "rent_or_mortgage" of 500 per month
    And I add 2999 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |  2999.0  |
    Then I should see the following "employment" details:
      | attribute                      | value    |
      | gross_income                   | 1115.15  |
      | tax                            | -1.4     |
      | national_insurance             | -38.78   |
      | net_employment_income          | 1029.97  |
    Then I should see the following "gross income" details:
      | attribute                      | value    |
      | total_gross_income             | 1615.15  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            | 500.0  |
      | dependant_allowance            | 296.65 |
      | total_outgoings_and_allowances | 881.83 |
      | total_disposable_income        | 733.32 |
      | income_contribution            | 203.97 |


