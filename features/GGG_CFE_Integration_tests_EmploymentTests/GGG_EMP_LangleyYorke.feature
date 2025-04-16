Feature:
  " Referred to a caseworker for employment "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add the following employment details:
      | client_id |     date     |  gross   | benefits_in_kind |   tax   | national_insurance  |
      |     C     |  2022-01-11  | 2083.33  |      0           | -206.00 |       -154.36       |
      |     C     |  2021-12-10  | 3083.33  |      0           | -406.00 |       -274.36       |
      |     C     |  2021-11-11  | 2000.00  |      0           | -189.40 |       -144.36       |
      |     C     |  2021-10-12  | 1750.00  |      0           | -139.40 |       -114.36       |
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
      | attribute                      | value    |
      | gross_income                   | 2229.17  |
      | tax                            | -235.2   |
      | national_insurance             | -171.86  |
      Then I should see the following "gross income" details:
        | attribute                    |  value   |
        | total_gross_income           |  2229.17 |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |   5.0  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 755.14 |
      | total_disposable_income        |1474.03 |
      | income_contribution            | 722.47 |
    And I should see the following remarks indicating caseworker referral
      | type                             |  issue           |
      | client_employment_payment        |unknown_frequency |


