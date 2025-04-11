Feature:
  " 1. ELIGIBLE
    2. Income & Capital contribution
    3. Employed - Calendar monthly "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-01-20"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE003     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 3
    And I add employment income of 2526 per month with 0.0 benefits_in_kind, 244.60 tax and 208.08 national insurance
    And I add other income "friends_or_family" of 10 per month
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 1200.00 |
    And I add outgoing details for "rent_or_mortgage" of 1200 per month
    And I add 4000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                |   value  |
      | total_liquid             |  4000.0  |
    Then I should see the following overall summary:
      | attribute                    | value   |
      | assessment_result            | contribution_required|
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | gross_income               | 2526.0   |
      | fixed_employment_deduction | -45.0    |
      | tax                        | -244.6   |
      | national_insurance         | -208.08  |
      | net_employment_income      | 2028.32  |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 2636.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            | 1200.0 |
      | total_outgoings_and_allowances |1994.33 |
      | total_disposable_income        | 641.67 |
      | income_contribution            | 139.82 |


