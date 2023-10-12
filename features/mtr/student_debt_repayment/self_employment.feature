Feature:
  "Self Employment (Deduct student debt repayments)"

  Scenario: The single client is self-employed and receiving a student debt repayment
    Given I am undertaking a controlled assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | student_debt_repayment |
      | monthly   | 1200.00  |  -50 |        -30          |         -50.0          |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  |  value |
      | gross_income               | 1200.0 |
      | fixed_employment_deduction |   0.0  |
      | tax                        | -50.0  |
      | national_insurance         | -30.0  |
      | student_debt_repayment     | -50.0  |
      | net_employment_income      | 1070.0 |

  Scenario: The single client is employed & self-employed and receiving a student debt repayment
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | student_debt_repayment | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 |        -50.0           |               false                            |
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    | tax |  national_insurance | student_debt_repayment |
      | monthly   | 1200.00  | -50 | -30                 |          -25           |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | gross_income               | 2400.0 |
      | fixed_employment_deduction | -45.0  |
      | tax                        | -100.0 |
      | national_insurance         | -60.0  |
      | student_debt_repayment     | -75.0  |
      | net_employment_income      | 2120.0 |
