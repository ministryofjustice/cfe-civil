Feature:
  "Checks that a pensioner capital disregard of £20,000 is applied. 
  This is because the client is over 60, is in receipt of a 
  passporting benefit and  have a disposable income of £224.22 per month."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2019-05-29"
    And A domestic abuse case
    And An Applicant of 61 years old
    And I have a dependant aged 14
    And I have a dependant aged 11
    And I have a dependant aged 9
    And I have a dependant aged 30
    And I have a dependant aged 32 with monthly income of 200
    And I add other income "friends_or_family" of 1415 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add a benefits regular_transactions of 200 every 4 weeks of credit
    And I add multiple outgoing details including "rent_or_mortgage" of 150 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add multiple outgoing details including "child_care" of 100 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add a non-disputed 50 percent share main property of value 500000 and mortgage 150000
    And I add the following vehicle details for the current assessment:
      | value                     |       9000 |
      | loan_amount_outstanding   |          0 |
      | date_of_purchase          | 2018-05-20 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | false      |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 1631.67 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | dependant_allowance            | 1257.45 |
      | gross_housing_costs            |   150.0 |
      | housing_benefit                |     0.0 |
      | net_housing_costs              |   150.0 |
      | total_outgoings_and_allowances | 1407.45 |
      | total_disposable_income        |  224.22 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |      0.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |   9000.0 |
      | total_mortgage_allowance    | 100000.0 |
      | total_capital               | 101500.0 |
      | pensioner_capital_disregard |  20000.0 |
      | assessed_capital            |  81500.0 |
      | capital_contribution        |  78500.0 |
