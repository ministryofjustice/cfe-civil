Feature:
    "Applicant is a pensioner, with 3 child and 2 adult dependents.
    They are an applicant in a non-molestation order case, so all upper thresholds don’t apply.
    Pensioner capital disregard is applied. They receive income from cash transactions.
    Outcome: capital contribution required. "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2019-05-29"
    And A domestic abuse case
    And An Applicant of 61 years old
    And I have a dependant aged 14
    And I have a dependant aged 11
    And I have a dependant aged 9
    And I have a dependant aged 30
    And I have a dependant aged 32
    And I add other income "friends_or_family" of 1215 per month, with bespoke dates: "2019-04-30" "2019-03-31" "2019-02-28"
    And I add a benefits regular_transactions of 200 every 4 weeks of credit
    And I add "friends_or_family" cash_transactions_income of 200 per month
    And I add multiple outgoing details including "rent_or_mortgage" of 50 per month, with bespoke dates: "2019-05-15" "2019-04-15" "2019-03-15"
    And I add multiple outgoing details including "child_care" of 25 per month, with bespoke dates: "2019-04-01" "2019-03-01" "2019-02-01"
    And I add 300 capital of type "bank_accounts"
    And I add 500 capital of type "non_liquid_capital"
    And I add a non-disputed 50 percent share main property of value 500000 and mortgage 150000
    And I add the following vehicle details for the current assessment:
      | value                     |       9000 |
      | loan_amount_outstanding   |          0 |
      | date_of_purchase          | 2018-05-20 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | false      |
    When I retrieve the final assessment
    Then I should see the following "proceeding_types" details where "ccms_code:DA001":
      | attribute               |              value    |
      | client_involvement_type |              A        |
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
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 1631.67 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 102300.0|
      | total_liquid                | 300.0   |
      | total_non_liquid            |  500.0  |
      | total_vehicle               | 9000.0  |
      | pensioner_capital_disregard | 60000.0 |
      | assessed_capital            | 42300.0 |
      | capital_contribution        | 39300.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 1457.45|
      | total_outgoings_and_allowances | 1507.45|
      | total_disposable_income        | 124.22 |
