Feature:
  " PASSPORTED s8 only
  Subject x 2
  Below upper capital contribution "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | A                       |
      | SE013     | W                       |
    And I add 3002 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   3002.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |   3002.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |      0.0 |
      | total_capital               |   3002.0 |
      | assessed_capital            |   3002.0 |
      | capital_contribution        |      2.0 |

