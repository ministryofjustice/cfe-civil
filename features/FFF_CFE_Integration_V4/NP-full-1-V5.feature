Feature:
    "Certificated assessment for an applicant in domestic abuse and child order proceedings.
    The client has 1 child dependant.
    Income from friends or family and student loan, outgoings for rent and capital from a bank account.
    The income and capital is below the lower thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
      | SE003     | A                       |
    And I have a dependant aged 2
    And I add other income "friends_or_family" of 100 per month
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount |
      | student_loan | annual    | 120.00 |
    And I add outgoing details for "rent_or_mortgage" of 10 per month
    And I add 2999 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | capital_lower_threshold        |   3000.0 |
      | gross_income_upper_threshold_1 |   2657.0 |
    Then I should see the following "gross_income_proceeding_types" details where "ccms_code:SE013":
      | attribute               | value    |
      | client_involvement_type | A        |
      | upper_threshold         |   2657.0 |
      | lower_threshold         |      0.0 |
      | result                  | eligible |
    Then I should see the following "capital summary" details:
      | attribute            | value  |
      | total_capital        | 2999.0 |
      | total_liquid         | 2999.0 |
      | total_non_liquid     |    0.0 |
      | total_vehicle        |    0.0 |
      | capital_contribution |    0.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | dependant_allowance            |  298.08 |
      | total_outgoings_and_allowances |  308.08 |
      | total_disposable_income        | -198.08 |
