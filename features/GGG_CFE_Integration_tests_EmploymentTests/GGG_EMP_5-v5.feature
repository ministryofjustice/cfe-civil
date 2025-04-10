Feature:
  " 1. Eligible
    2. Income contribution
    3. Employed - Multiple employment "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add four-weekly employment income with the following payments:
      | period   | income | tax   | ni |
      | period 1 | 267.38 |   0.0 | 0  |
      | period 2 | 278.74 |   0.0 | 0  |
      | period 3 | 353.35 |   0.0 | 0  |
      | period 4 | 619.48 |   0.0 | 0  |
      | period 5 | 522.50 |   0.0 | 0  |
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
#    Then I should see the following overall summary:
#      | attribute                      | value    |
#      | assessment_result              | eligible |
    Then I should see the following "gross income" details:
      | attribute                      | value  |
      | total_gross_income             | 442.31 |
    Then I should see the following "capital summary" details:
      | attribute                      | value  |
      | total_capital                  |  500.0 |
      | assessed_capital               |  500.0 |
      | capital_contribution           |   0.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value |
      | gross_housing_costs            |     5.0 |
      | dependant_allowance            |  298.08 |
      | total_outgoings_and_allowances |  348.08 |
      | total_disposable_income        |   94.23 |


