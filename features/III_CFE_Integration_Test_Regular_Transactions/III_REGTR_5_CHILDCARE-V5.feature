Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client is employed, has 1 child dependant, income from employment and outgoings for child care. 
  The gross income and disposable income are below the thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following employment details:
      | client_id | date       | gross | benefits_in_kind | tax  | national_insurance |
      | C         | 2021-11-11 | 572.8 |                0 |  0.0 |                0.0 |
      | C         | 2021-10-14 | 572.8 |                0 |  0.0 |                0.0 |
      | C         | 2021-09-16 | 572.8 |                0 |  0.0 |                0.0 |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 1
    And I add "child_care" of multiple regular_transactions, of 111.11 per month
    And I add "child_care" of multiple regular_transactions, of 222 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | eligible |
      | capital_lower_threshold |   3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value  |
      | total_gross_income | 620.53 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 676.19 |
      | total_disposable_income        | -55.66 |
