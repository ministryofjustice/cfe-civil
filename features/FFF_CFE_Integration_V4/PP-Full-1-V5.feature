Feature:
    "Certificated assessment for an applicant in domestic abuse and child order proceedings.
    The client is passported and has capital from a bank account.
    The income and capital are below the lower thresholds therefore the overall result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And An applicant who receives passporting benefits
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
      | SE003     | A                       |
    And I add 2999.0 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following "proceeding_types" details where "ccms_code:DA001":
      | attribute               |              value    |
      | client_involvement_type |              A        |
      | result                  | eligible              |
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
    Then I should see the following "proceeding_types" details where "ccms_code:SE013":
      | attribute               |              value    |
      | client_involvement_type |              A        |
      | result                  |   eligible            |
    And I should see the following "gross_income_proceeding_types" details where "ccms_code:SE013":
      | attribute        |        value    |
      | upper_threshold  | 2657.0          |
    And I should see the following "disposable_income_proceeding_types" details where "ccms_code:SE013":
      | attribute        |        value    |
      | lower_threshold  | 315.0           |
      | upper_threshold  | 733.0           |
    And I should see the following "capital_proceeding_types" details where "ccms_code:SE013":
      | attribute        |        value    |
      | lower_threshold  | 3000.0          |
      | upper_threshold  | 8000.0          |
    Then I should see the following "proceeding_types" details where "ccms_code:SE003":
      | attribute               |              value    |
      | client_involvement_type |              A        |
      | result                  |   eligible            |
    And I should see the following "gross_income_proceeding_types" details where "ccms_code:SE003":
      | attribute        |        value    |
      | upper_threshold  | 2657.0          |
    And I should see the following "disposable_income_proceeding_types" details where "ccms_code:SE003":
      | attribute        |        value    |
      | lower_threshold  | 315.0           |
      | upper_threshold  | 733.0           |
    And I should see the following "capital_proceeding_types" details where "ccms_code:SE003":
      | attribute        |        value    |
      | lower_threshold  | 3000.0          |
      | upper_threshold  | 8000.0          |
    Then I should see the following overall summary:
      | attribute                      | value              |
      | assessment_result              | eligible           |
      | capital_lower_threshold        | 3000.0             |
      | gross_income_upper_threshold_1 | 2657.0             |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 0.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 2999.0  |
      | total_liquid                | 2999.0  |
      | total_non_liquid            |    0.0  |
      | total_vehicle               |    0.0  |
      | pensioner_capital_disregard |    0.0  |
      | assessed_capital            | 2999.0  |
      | capital_contribution        |    0.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 0      |
      | total_outgoings_and_allowances | 0.0    |
      | total_disposable_income        | 0.0    |
