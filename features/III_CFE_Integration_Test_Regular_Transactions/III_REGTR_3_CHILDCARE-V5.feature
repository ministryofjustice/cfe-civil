Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client has no dependants, income from student loans and outgoings for child care.
  The outgoings for child care are not included as the client has no dependants.
  The disposable income is above the lower threshold therefore the overall result is income contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 4800.00 |
    And I add "child_care" of multiple regular_transactions, of 111.11 per month of debit
    And I add "child_care" of multiple regular_transactions, of 222 per month of debit
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 400.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute               | value |
      | total_disposable_income | 400.0 |
      | income_contribution     | 31.15 |
