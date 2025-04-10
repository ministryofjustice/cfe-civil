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
    And I add the following employment details:
      | client_id |     date     |  gross   | benefits_in_kind |   tax  | national_insurance  |
      |     C     |  2021-12-10  |   267.38 |      0           |   0.0  |          0.0        |
      |     C     |  2021-11-12  |   278.74 |      0           |   0.0  |          0.0        |
      |     C     |  2021-10-15  |   353.35 |      0           |   0.0  |          0.0        |
      |     C     |  2021-09-17  |   619.48 |      0           |   0.0  |          0.0        |
      |     C     |  2021-08-20  |   522.50 |      0           |   0.0  |          0.0        |
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
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
    And I should see the following remarks indicating caseworker referral
      | type                            |  issue           |
      | client_employment_tax           | refunds          |
      | client_employment_nic           | refunds          |


