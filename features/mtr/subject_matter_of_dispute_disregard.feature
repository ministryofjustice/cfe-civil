Feature:
  "Subject Matter Of Dispute Disregard Cap"

  Scenario: SMOD Disregard Cap is applied
    Given I am undertaking a certificated assessment
    And A submission date of "2020-04-10"
    And I add disputed main property
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | subject_matter_of_dispute_disregard | 100000.0 |

  Scenario: SMOD Disregard Cap is removed under MTR rules
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add disputed main property
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | subject_matter_of_dispute_disregard | 194000.0 |
