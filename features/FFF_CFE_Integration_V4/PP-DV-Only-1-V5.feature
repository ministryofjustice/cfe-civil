Feature:
    "1.DV proceedings Only
     2. Contribution capital
     3. Above upper limit"

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2021-05-10"
    And An applicant who receives passporting benefits
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | DA004     | A                       |
    And I add 8050.0 capital of type "bank_accounts"
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
    Then I should see the following "proceeding_types" details where "ccms_code:DA004":
      | attribute               |              value      |
      | client_involvement_type |              A          |
      | result                  |   contribution_required |
    And I should see the following "gross_income_proceeding_types" details where "ccms_code:DA004":
      | attribute        |        value    |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "disposable_income_proceeding_types" details where "ccms_code:DA004":
      | attribute        |        value    |
      | lower_threshold  | 315.0           |
      | upper_threshold  | 999999999999.0  |
    And I should see the following "capital_proceeding_types" details where "ccms_code:DA004":
      | attribute        |        value    |
      | lower_threshold  | 3000.0          |
      | upper_threshold  | 999999999999.0  |
    Then I should see the following overall summary:
      | attribute                      | value                |
      | assessment_result              | contribution_required|
      | capital_lower_threshold        | 3000.0               |
      | gross_income_upper_threshold_1 | 999999999999.0       |
    Then I should see the following "gross income" details:
      | attribute          | value |
      | total_gross_income | 0.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value   |
      | total_capital               | 8050.0  |
      | total_liquid                | 8050.0  |
      | total_non_liquid            |    0.0  |
      | total_vehicle               |    0.0  |
      | pensioner_capital_disregard |    0.0  |
      | assessed_capital            | 8050.0  |
      | capital_contribution        | 5050.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value  |
      | dependant_allowance            | 0      |
      | total_outgoings_and_allowances | 0.0    |
      | total_disposable_income        | 0.0    |
