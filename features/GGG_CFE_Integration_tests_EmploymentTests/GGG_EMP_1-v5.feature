Feature:
  "Employed Multiple Incomes test"

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 2
    And I add employment income of 2550.33 per month with 0.0 benefits_in_kind, 745.31 tax and 144.06 national insurance
    And I add employment income of 250 per week with 0 benefits_in_kind, 0 tax and 80 national insurance
    And I add outgoing details for "rent_or_mortgage" of 550 per month
    And I add 1215.44 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                | value    |
      | total_liquid             |  1215.44 |
    Then I should see the following overall summary:
      | attribute                    | value   |
      | assessment_result            | eligible|
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |  550.0 |
      | total_outgoings_and_allowances | 893.08 |
      | total_disposable_income        |-893.08 |
      | income_contribution            |    0.0 |


