Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client is employed, has 1 adult dependant and outgoings for child care.
  The outgoings for child care are not included as the client only has an adult dependant.
  The gross income and disposable income are below the thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 20
    And I add "child_care" of multiple regular_transactions, of 111.11 per month of "debit"
    And I add "child_care" of multiple regular_transactions, of 222 per month of "debit"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | eligible |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income |   0.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | dependant_allowance     |  298.08 |
      | total_disposable_income | -298.08 |
