Feature:
  "
  NON-PASSPORTED
  Applicant & Defendant
  Above all upper thresholds
  Partially eligible
  "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | D                       |
    And I have a dependant aged 1
    And I add employment income of 2700 per month with 0 benefits_in_kind, 0 tax and 0 national insurance
    And I add outgoing details for "rent_or_mortgage" of 550 per month
    And I add 10000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value              |
      | assessment_result              | partially_eligible |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   | 10000.0  |
    Then I should see the following "gross income" details:
      | attribute                      |  value   |
      | total_gross_income             |  2700.0  |
    Then I should see the following "employment" details:
      | attribute                      | value   |
      | gross_income                   | 2700.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value  |
      | gross_housing_costs            |   550.0  |
      | dependant_allowance            |  298.08  |
      | total_outgoings_and_allowances |  893.08  |
      | total_disposable_income        | 1806.92  |
      | income_contribution            |  955.49  |


