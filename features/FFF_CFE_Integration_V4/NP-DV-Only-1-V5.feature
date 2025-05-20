Feature:
    "Certificated assessment for an applicant in domestic abuse proceedings.
    The client has 1 child dependant. Income from friends or family,
    outgoings for rent and capital from a bank account.
    The capital is above the thresholds therefore the overall result is capital contributions required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | DA004     | A                       |
    And I have a dependant aged 2
    And I add other income "friends_or_family" of 300 per month
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 10000.0 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                         |
      | assessment_result              | contribution_required         |
      | capital_lower_threshold        |                3000.0         |
      | gross_income_upper_threshold_1 |                999999999999.0 |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 300.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value  |
      | total_capital               | 10000.0 |
      | total_liquid                | 10000.0 |
      | total_non_liquid            |    0.0 |
      | total_vehicle               |    0.0 |
      | pensioner_capital_disregard |    0.0 |
      | assessed_capital            | 10000.0 |
      | capital_contribution        | 7000.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 303.08 |
      | total_disposable_income        | -3.08  |
