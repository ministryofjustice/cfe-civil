Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client has 1 child dependant, student loan income, other regular incomes/outgoings at varying frequencies (inc. housing benefit) and friends or family ‘cash’ income.
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
    And I add "benefits" of multiple regular_transactions, of 33.33, "three_monthly" of "credit"
    And I add "friends_or_family" of multiple regular_transactions, of 22.22, "monthly" of "credit"
    And I add "maintenance_in" of multiple regular_transactions, of 51.28, "four_weekly" of "credit"
    And I add "property_or_lodger" of multiple regular_transactions, of 41.02, "two_weekly" of "credit"
    And I add "pension" of multiple regular_transactions, of 3.03, "weekly" of "credit"
    And I add "housing_benefit" of multiple regular_transactions, of 300, "three_monthly" of "credit"
    And I add "child_care" of multiple regular_transactions, of 333.33, "three_monthly" of "debit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 222.22, "monthly" of "debit"
    And I add "maintenance_out" of multiple regular_transactions, of 512.82, "four_weekly" of "debit"
    And I add "legal_aid" of multiple regular_transactions, of 410.25, "two_weekly" of "debit"
    And I add "friends_or_family" of multiple regular_transactions, of 222, "monthly" of "credit"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute         | value    |
      | assessment_result | eligible |
    Then I should see the following "gross income" details:
      | attribute          | value  |
      | total_gross_income | 812.89 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | maintenance_allowance          |   555.56 |
      | housing_benefit                |    100.0 |
      | net_housing_costs              |   122.22 |
      | total_outgoings_and_allowances |  1975.85 |
      | total_disposable_income        | -1162.96 |
      | dependant_allowance            |   298.08 |
