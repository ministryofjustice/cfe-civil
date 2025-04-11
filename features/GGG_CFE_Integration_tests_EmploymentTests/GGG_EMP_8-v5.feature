Feature:
  " 1. Most recent (within £60 tolerance)
    2. Variations - MOST RECENT
    3. 4 weekly "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add four-weekly employment income with the following payments:
      | period   | income | tax   | ni   |
      | period 1 | 267.38 |  10.0 | 5.0  |
      | period 2 | 278.74 |  12.0 | 6.0  |
      | period 3 | 250.01 |   8.0 | 3.0  |
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   500.0  |
    Then I should see the following "employment" details:
      | attribute                      | value    |
      | gross_income                   |  289.66  |
      | tax                            |  -10.83  |
      | national_insurance             |   -5.42  |
      | net_employment_income          |   226.6  |
    Then I should see the following "gross income" details:
      | attribute                      | value   |
      | total_gross_income             | 289.66  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |   5.0  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 364.33 |
      | total_disposable_income        | -74.67 |


