Feature:
  "Self Employment"

  Scenario: The single client is self-employed
    Given I am undertaking a controlled assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | prisoner_levy |
      | monthly   | 1200.00  |  -50 |        -30          |    -20.0      |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  |  value |
      | gross_income               | 1200.0 |
      | fixed_employment_deduction |   0.0  |
      | tax                        | -50.0  |
      | national_insurance         | -30.0  |
      | prisoner_levy              | -20.0  |
      | net_employment_income      | 1100.0 |

  Scenario: The single client is employed & self-employed
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | prisoner_levy | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 |    -20.0      |                false                           |
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    | tax |  national_insurance | prisoner_levy |
      | monthly   | 1200.00  | -50 | -30                 |    -10.0      |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | gross_income               | 2400.0 |
      | fixed_employment_deduction | -45.0  |
      | tax                        | -100.0 |
      | national_insurance         | -60.0  |
      | prisoner_levy              | -30.0  |
      | net_employment_income      | 2165.0 |
