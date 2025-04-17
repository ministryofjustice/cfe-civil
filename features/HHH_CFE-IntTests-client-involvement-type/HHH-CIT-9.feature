Feature:
  " NON-PASSPORTED S8 STANDALONE
  Applicant & Defendant
  Above DI upper threshold
  Not eligible "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | W                       |
      | SE013     | D                       |
    And I have a dependant aged 1
    And I add employment income of 1500 per month with 0 benefits_in_kind, 0 tax and 0 national insurance
    And I add outgoing details for "rent_or_mortgage" of 400 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | ineligible |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   500.0  |
    Then I should see the following "employment" details:
      | attribute                      | value     |
      | gross_income                   | 1500.0    |
      | tax                            |    0.0    |
      | national_insurance             |    0.0    |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value  |
      | gross_housing_costs            |   400.0  |
      | dependant_allowance            |  298.08  |
      | total_outgoings_and_allowances |  743.08  |
      | total_disposable_income        |  756.92  |


