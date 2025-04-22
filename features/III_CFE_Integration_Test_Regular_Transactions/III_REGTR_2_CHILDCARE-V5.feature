Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client has 1 child dependant, income from student loans and outgoings for child care.
  The gross income and disposable income are below the thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 1
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 4800.00 |
    And I add "child_care" of multiple regular_transactions, of 111.11 per month of "debit"
    And I add "child_care" of multiple regular_transactions, of 222 per month of "debit"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | eligible |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 400.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | dependant_allowance            |  298.08 |
      | total_outgoings_and_allowances |  631.19 |
      | total_disposable_income        | -231.19 |
