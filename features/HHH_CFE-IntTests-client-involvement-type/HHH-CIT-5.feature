Feature:
  " PASSPORTED
  Defendant x 2
  Above upper capital
  Ineligible "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | D                       |
      | SE013     | D                       |
    And I add 3005 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |   3005.0 |
      | total_non_liquid            |      0.0 |
      | total_vehicle               |      0.0 |
      | total_capital               |   3005.0 |
      | assessed_capital            |   3005.0 |
      | capital_contribution        |      5.0 |

