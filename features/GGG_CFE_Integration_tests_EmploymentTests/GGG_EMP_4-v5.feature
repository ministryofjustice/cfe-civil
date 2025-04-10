Feature:
  " 1. Eligible
    2. Income contribution
    3. Employed - Multiple employment "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-05"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | DA004     | A                       |
    And I have a dependant aged 3
    And I add four-weekly employment income with the following payments:
      | period   | income | tax   | ni   |
      | period 1 | 272.0  | 80.20 | 0    |
      | period 2 | 304.73 | 115.81| 0    |
      | period 3 | 429.41 | 215.21| 0    |
      | period 4 | 935.56 | 416.18| 23.95|
    And I add weekly employment income with the following payments:
      | period   | income | tax   | ni  |
      | week 1   | 142.56 | 28.40 | 0   |
      | week 2   | 142.56 | 28.40 | 0   |
      | week 3   | 142.56 | 28.40 | 0   |
      | week 4   | 89.10  | 17.80 | 0   |
    And I add other income "friends_or_family" of 300 per month
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 10000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |
    Then I should see the following "gross income" details:
      | attribute               | value |
      | total_gross_income      | 300.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |  10000.0 |
      | total_capital               |  10000.0 |
      | assessed_capital            |  10000.0 |
      | capital_contribution        |   7000.0 |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value |
      | gross_housing_costs            |     5.0 |
      | total_outgoings_and_allowances |  348.08 |
      | total_disposable_income        |  -48.08 |


