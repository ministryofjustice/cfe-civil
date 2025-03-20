Feature:
  "Certificated domestic abuse assessment which is passported.
  The submission date is before 28/01/21 so old rules are applied.
  Capital includes an additional home. Assessed capital is over
  the lower threshold so the result is capital contribution required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A domestic abuse case
    And An applicant who receives passporting benefits
    And A submission date of "2021-01-27"
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
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |      0.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |      0.0 |
      | total_mortgage_allowance    | 100000.0 |
      | total_capital               | 118250.0 |
      | pensioner_capital_disregard |      0.0 |
      | assessed_capital            | 118250.0 |
      | capital_contribution        | 115250.0 |
