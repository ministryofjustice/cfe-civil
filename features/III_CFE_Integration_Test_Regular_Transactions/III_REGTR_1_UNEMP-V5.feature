Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client has 1 child dependant, various regular incomes/outgoings and friends or family ‘cash’ income. 
  The gross income and disposable income are below the thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 1
    And I add "benefits" of multiple regular_transactions, of 11.11, "monthly" of "credit"
    And I add "friends_or_family" of multiple regular_transactions, of 22.22, "monthly" of "credit"
    And I add "maintenance_in" of multiple regular_transactions, of 55.55, "monthly" of "credit"
    And I add "property_or_lodger" of multiple regular_transactions, of 88.88, "monthly" of "credit"
    And I add "pension" of multiple regular_transactions, of 13.13, "monthly" of "credit"
    And I add "child_care" of multiple regular_transactions, of 111.11, "monthly" of "debit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 222.22, "monthly" of "debit"
    And I add "maintenance_out" of multiple regular_transactions, of 555.55, "monthly" of "debit"
    And I add "legal_aid" of multiple regular_transactions, of 888.88, "monthly" of "debit"
    And I add "friends_or_family" of multiple regular_transactions, of 222.0, "monthly" of "credit"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | eligible |
    Then I should see the following "gross income" details:
      | attribute          | value  |
      | total_gross_income | 412.89 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | maintenance_allowance          |   555.55 |
      | gross_housing_costs            |   222.22 |
      | housing_benefit                |      0.0 |
      | net_housing_costs              |   222.22 |
      | total_outgoings_and_allowances |  1964.73 |
      | total_disposable_income        | -1551.84 |
      | dependant_allowance            |   298.08 |
