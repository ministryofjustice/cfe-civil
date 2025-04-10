Feature:
  " 1. Blunt average (without £60 tolerance)
    2. Variations - Blunt average
    3. 4 weekly
    4. Remarks for average "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add four-weekly employment income with the following payments:
      | period   | income | tax   | ni    |
      | period 1 | 267.38 |  10.0 |  5.0  |
      | period 2 | 310.00 |  21.0 | 11.0  |
      | period 3 | 250.01 |   8.0 |  3.0  |
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
      | gross_income                   | 298.78   |
      | tax                            | -14.08   |
      | national_insurance             | -6.86    |
      | net_employment_income          | 232.84   |
    Then I should see the following "gross income" details:
      | attribute                      |  value   |
      | total_gross_income             |  298.78  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |   5.0  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 369.02 |
      | total_disposable_income        | -70.24 |
      | income_contribution            |    0.0 |
    And I should see the following remarks indicating caseworker referral
      | type                            |  issue           |
      | client_employment_income        | amount_variation |

