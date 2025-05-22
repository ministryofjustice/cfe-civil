Feature:
    "Certificated assessment for an applicant in domestic abuse proceedings.
    The client has 3 child dependants and 2 adult dependants (one of which has income) and post 12th April 2020 rates applied.
    Income from friends/family and child benefit at irregular dates and outgoings for mortgage and childcare but this is not included as there is no employment income.
    Capital includes main home and vehicle. The capital is over the upper threshold but waived therefore the result is capital contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-04-13"
    And A domestic abuse case
    And I have a dependant aged 16
    And I have a dependant aged 13
    And I have a dependant aged 11
    And I have a dependant aged 32 with monthly income of 0 and capital 1000
    And I have a dependant aged 34 with monthly income of 200 and capital 7999
    And I add other income "friends_or_family" of 1415 per month, with bespoke dates: "2019-04-30" "2019-03-31" "2019-02-28"
    And I add a benefits regular_transactions of 200 every 4 weeks of credit
    And I add multiple outgoing details including "rent_or_mortgage" of 50 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add multiple outgoing details including "child_care" of 100 per month, with bespoke dates: "2019-04-15" "2019-04-15" "2019-03-15"
    And I add a non-disputed 50 percent share main property of value 500000 and mortgage 150000
    And I add the following vehicle details for the current assessment:
      | value                     |       9000 |
      | loan_amount_outstanding   |          0 |
      | date_of_purchase          | 2018-05-20 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | false      |
    When I retrieve the final assessment
    Then I should see the following "proceeding_types" details where "ccms_code:DA001":
      | attribute               | value                 |
      | client_involvement_type | A                     |
      | result                  | contribution_required |
    And I should see the following "gross_income_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "disposable_income_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | lower_threshold  | 315.0           |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "capital_proceeding_types" details where "ccms_code:DA001":
      | attribute        |        value    |
      | lower_threshold  | 3000.0          |
      | upper_threshold  | 999999999999.0  |
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |   3000.0              |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 1631.67 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 76500.0 |
      | total_liquid                | 0.0     |
      | total_non_liquid            | 0.0     |
      | total_vehicle               | 9000.0  |
      | pensioner_capital_disregard | 0.0     |
      | assessed_capital            | 76500.0 |
      | capital_contribution        | 73500.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 1290.4 |
      | total_outgoings_and_allowances | 1340.4 |
      | total_disposable_income        | 291.27 |
