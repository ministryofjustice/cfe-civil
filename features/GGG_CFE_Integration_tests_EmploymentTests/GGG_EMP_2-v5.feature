Feature:
  "Employed 4 weekly Incomes test"

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-12-01"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
      | SE003     | A                       |
    And I have a dependant aged 3
    And I add employment income of 572.80 every 4 weeks with 0.0 benefits_in_kind, 0.0 tax and 0.0 national insurance
    And I add other income "friends_or_family" of 2000 per month
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 1200.00 |
    And I add outgoing details for "rent_or_mortgage" of 250 per month
    And I add 9000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value              |
      | assessment_result            | partially_eligible |
    Then I should see the following "gross income" details:
      | attribute               | value   |
      | total_gross_income      | 2720.53 |
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | gross_income               | 620.53  |
      | net_employment_income      | 575.53  |
    Then I should see the following "capital summary" details:
      | attribute                | value    |
      | total_liquid             |  9000.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value |
      | gross_housing_costs            |   250.0 |
      | total_outgoings_and_allowances |  593.08 |
      | total_disposable_income        | 2127.45 |
      | income_contribution            | 1179.87 |
    And I should see the following remarks indicating caseworker referral
      | type                            |  issue           |
      | client_employment_tax           | refunds          |
      | client_employment_nic           | refunds          |


