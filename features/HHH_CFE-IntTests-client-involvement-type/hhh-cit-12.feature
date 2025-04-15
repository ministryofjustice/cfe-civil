Feature:
  " NON-PASSPORTED mix & all CIT
  Partial
  "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA004     | A                       |
      | SE013     | D                       |
      | SE014     | I                       |
      | DA003     | W                       |
      | SE003     | Z                       |
    And I have a dependant aged 1
    And I add employment income of 900 per month with 0 benefits_in_kind, 0 tax and 0 national insurance
    And I add outgoing details for "rent_or_mortgage" of 520 per month
    And I add 11220 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value              |
      | assessment_result              | partially_eligible |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   | 11220.0  |
    Then I should see the following "employment" details:
      | attribute                      |  value   |
      | gross_income                   |  900.0   |
      | tax                            |    0.0   |
      | national_insurance             |    0.0   |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |  11220.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |      0.0 |
      | total_capital               |  11220.0 |
      | assessed_capital            |  11220.0 |
      | capital_contribution        |   8220.0 |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value  |
      | gross_housing_costs            |   520.0  |
      | dependant_allowance            |  298.08  |
      | total_outgoings_and_allowances |  863.08  |
      | total_disposable_income        |   36.92  |
      | income_contribution            |     0.0  |


