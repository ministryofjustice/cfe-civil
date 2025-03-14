Feature:
  "Certificated domestic abuse assessment which is not passported.
  The submission date is before 28/01/21 so old rules are applied.
  Income includes child benefit. Capital includes a main home. 
  Assessed capital is over the lower threshold so the result is capital contribution required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A domestic abuse case
    And A submission date of "2021-01-27"
    And I add a benefits regular_transactions of 22.42 per month of credit
    And I add a non-disputed 100 percent share main property of value 225000 and mortgage 210000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 22.42 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value |
      | gross_housing_costs            |   0.0 |
      | housing_benefit                |   0.0 |
      | net_housing_costs              |   0.0 |
      | total_outgoings_and_allowances |   0.0 |
      | total_disposable_income        | 22.42 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |      0.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |      0.0 |
      | total_mortgage_allowance    | 100000.0 |
      | total_capital               |  18250.0 |
      | pensioner_capital_disregard |      0.0 |
      | assessed_capital            |  18250.0 |
      | capital_contribution        |  15250.0 |