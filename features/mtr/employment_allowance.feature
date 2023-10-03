Feature:
  "Fixed Employment Allowance Threshold"

  Scenario: Case after MTR data
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 400 per month
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | fixed_employment_deduction | -66.0  |
