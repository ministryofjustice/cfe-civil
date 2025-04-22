Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings.
  The client has 1 child dependant, multiple employment incomes, student loan income, various regular incomes/outgoings and friends or family ‘cash’ income.
  The gross income and disposable income are below the thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 1
    And I add the following employment details:
      | client_id | date       | gross   | benefits_in_kind | tax     | national_insurance |
      | C         | 2021-12-30 | 2550.33 |                0 | -745.31 |            -144.06 |
      | C         | 2021-11-30 | 2550.33 |                0 | -745.31 |            -144.06 |
      | C         | 2021-10-30 | 2550.33 |                0 | -745.31 |            -144.06 |
    And I add the following employment details:
      | client_id | date       | gross  | benefits_in_kind | tax    | national_insurance |
      | C         | 2021-12-07 | 250.00 |                0 | -80.00 |                  0 |
      | C         | 2021-12-14 | 250.00 |                0 | -80.00 |                  0 |
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 4800.00 |
    And I add "benefits" of multiple regular_transactions, of 111.11, "monthly" of "credit"
    And I add "friends_or_family" of multiple regular_transactions, of 100, "monthly" of "credit"
    And I add "maintenance_in" of multiple regular_transactions, of 444.44, "monthly" of "credit"
    And I add "property_or_lodger" of multiple regular_transactions, of 100, "monthly" of "credit"
    And I add "pension" of multiple regular_transactions, of 100, "monthly" of "credit"
    And I add "child_care" of multiple regular_transactions, of 111.11, "monthly" of "debit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 222.22, "monthly" of "debit"
    And I add "maintenance_out" of multiple regular_transactions, of 333.33, "monthly" of "debit"
    And I add "legal_aid" of multiple regular_transactions, of 444.44, "monthly" of "debit"
    And I add "friends_or_family" of multiple regular_transactions, of 222, "monthly" of "credit"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute         | value    |
      | assessment_result | eligible |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 1477.55 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | maintenance_allowance          |  333.33 |
      | housing_benefit                |     0.0 |
      | net_housing_costs              |  222.22 |
      | total_outgoings_and_allowances | 1454.18 |
      | total_disposable_income        |   23.37 |
      | dependant_allowance            |  298.08 |
    And I should see the following remarks indicating caseworker referral
      | type              | issue                |
      | client_employment | multiple_employments |
