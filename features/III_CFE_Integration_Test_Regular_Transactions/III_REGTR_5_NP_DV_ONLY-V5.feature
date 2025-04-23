Feature:
  "Certificated assessment for an applicant in domestic abuse proceedings.
  The client has 1 child dependant, regular friends or family income, rent or mortgage outgoings and capital from a bank account.
  The capital is over the upper threshold therefore the overall result is capital contribution required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | DA004     | A                       |
    And I have a dependant aged 2
    And I add "friends_or_family" of multiple regular_transactions, of 300, "monthly" of "credit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 5, "monthly" of "debit"
    And I add 10000.00 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute         | value                 |
      | assessment_result | contribution_required |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 300.0 |
    And I should see the following "capital summary" details:
      | attribute     | value   |
      | total_capital | 10000.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | maintenance_allowance          |    0.0 |
      | housing_benefit                |    0.0 |
      | net_housing_costs              |    5.0 |
      | total_outgoings_and_allowances | 303.08 |
      | total_disposable_income        |  -3.08 |
      | dependant_allowance            | 298.08 |
