Feature:
  "Property Disregard Main Home Threshold"

  Scenario: Case after MTR data
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add non-disputed main property
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | main_home_equity_disregard | 185000.0 |

