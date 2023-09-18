Feature:
  "Fixed Employment Allowance Threshold"

  Scenario: Case after MTR data
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And A submission date of "2525-04-10"
    And I add the employment details
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | fixed_employment_deduction | -66.0  |

