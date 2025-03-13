Feature:
  "Certificated domestic abuse assessment which is not passported.
  The submission date is after 28/01/21 so new rules are applied.
  There is no income. Capital includes an additional home.
  Assessed capital is over the lower threshold so the result is capital contribution required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A domestic abuse case
    And A submission date of "2021-01-28"
    And I add a non-disputed 0 percent share main property of value 0 and mortgage 0
    And I add the following additional property details for the current assessment:
      | value                     | 225000.00 |
      | outstanding_mortgage      | 210000.00 |
      | percentage_owned          |       100 |
      | shared_with_housing_assoc | false     |
      | subject_matter_of_dispute | false     |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income |   0.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value |
      | gross_housing_costs            |   0.0 |
      | housing_benefit                |   0.0 |
      | net_housing_costs              |   0.0 |
      | total_outgoings_and_allowances |   0.0 |
      | total_disposable_income        |   0.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value          |
      | total_liquid                |            0.0 |
      | total_non_liquid            |            0.0 |
      | total_vehicle               |            0.0 |
      | total_mortgage_allowance    | 999999999999.0 |
      | total_capital               |         8250.0 |
      | pensioner_capital_disregard |            0.0 |
      | assessed_capital            |         8250.0 |
      | capital_contribution        |         5250.0 |
