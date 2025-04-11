Feature:
  " 1. Most recent (within £60 tolerance)
    2. Variations - MOST RECENT
    3. 1 weekly "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add weekly employment income with the following payments:
      | period   | income | tax   | ni    |
      | week 1   |  220.0 |   5.0 | 3.0   |
      | week 2   |  201.0 |   0.0 | 0.0   |
      | week 3   |  220.0 |   5.0 | 3.0   |
      | week 4   |  201.0 |   0.0 | 0.0   |
      | week 5   |  220.0 |   5.0 | 3.0   |
      | week 6   |  201.0 |   0.0 | 0.0   |
      | week 7   |  220.0 |   5.0 | 3.0   |
      | week 8   |  201.0 |   0.0 | 0.0   |
      | week 9   |  220.0 |   5.0 | 3.0   |
      | week 10  |  201.0 |   0.0 | 0.0   |
      | week 11  |  220.0 |   5.0 | 3.0   |
      | week 12  |  201.0 |   0.0 | 0.0   |
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   500.0  |
    Then I should see the following "employment" details:
      | attribute                      | value   |
      | gross_income                   | 912.17  |
      | tax                            | -10.84  |
      | national_insurance             |   -6.5  |
      Then I should see the following "gross income" details:
        | attribute                    |  value   |
        | total_gross_income           |  912.17  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |   5.0  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 365.42 |
      | total_disposable_income        | 546.75 |
      | income_contribution            |  90.69 |


