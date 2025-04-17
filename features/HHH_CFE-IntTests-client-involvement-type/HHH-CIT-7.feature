Feature:
  " PASSPORTED s8 only
  Subject x 2
  Above upper capital
  Ineligible "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-24"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | W                       |
      | SE013     | W                       |
    And I add 8001 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | ineligible |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   8001.0 |

