Feature:
  " NON-PASSPORTED S8 STANDALONE
  Applicant & Defendant
  Contributions "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | D                       |
      | SE013     | A                       |
    And I have a dependant aged 1
    And I add employment income of 1500 per month with 0 benefits_in_kind, 0 tax and 0 national insurance
    And I add outgoing details for "rent_or_mortgage" of 520 per month
    And I add 4350 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   4350.0 |
    Then I should see the following "employment" details:
      | attribute                      | value     |
      | gross_income                   | 1500.0    |
      | tax                            |    0.0    |
      | national_insurance             |    0.0    |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value  |
      | gross_housing_costs            |   520.0  |
      | dependant_allowance            |  298.08  |
      | total_outgoings_and_allowances |  863.08  |
      | total_disposable_income        |  636.92  |
      | income_contribution            |  136.49  |


