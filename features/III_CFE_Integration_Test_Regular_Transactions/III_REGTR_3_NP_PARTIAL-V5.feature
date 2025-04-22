Feature:
  "Certificated assessment for an applicant in domestic abuse and child order proceedings. 
  The client has 1 child dependant, student loan income, regular friends or family income, rent or mortgage outgoings and capital from a bank account. 
  The disposable income and capital are over the thresholds therefore the overall result is partially eligible and income and capital contribution are required for the DA proceedings."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
      | SE003     | A                       |
    And I have a dependant aged 2
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 1200.00 |
    And I add "friends_or_family" of multiple regular_transactions, of 2000, "monthly" of "credit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 250, "monthly" of "debit"
    And I add 9000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute         | value              |
      | assessment_result | partially_eligible |
    Then I should see the following "gross income" details:
      | attribute          | value  |
      | total_gross_income | 2100.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | maintenance_allowance          |     0.0 |
      | housing_benefit                |     0.0 |
      | gross_housing_costs            |   250.0 |
      | net_housing_costs              |   250.0 |
      | total_outgoings_and_allowances |  548.08 |
      | total_disposable_income        | 1551.92 |
      | dependant_allowance            |  298.08 |
