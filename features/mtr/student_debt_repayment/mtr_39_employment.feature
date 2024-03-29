Feature:
    "Employment (Deduct student debt repayments)"

    Scenario: The client is employed, and receiving a student debt repayment
      Given I am undertaking a certificated assessment
      And I add the following employment details:
        | client_id |     date     |  gross | benefits_in_kind |  tax   | national_insurance  | student_debt_repayment |
        |     C     |  2022-06-22  | 500.00 |      0           | -55.00 |       -25.0         |        -50.0           |
        |     C     |  2022-07-22  | 500.00 |      0           | -55.00 |       -25.0         |        -50.0           |
        |     C     |  2022-08-22  | 500.00 |      0           | -55.00 |       -25.0         |        -50.0           |
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value  |
            | gross_income               | 500.0  |
            | fixed_employment_deduction | -45.0  |
            | tax                        | -55.0  |
            | national_insurance         | -25.0  |
            | student_debt_repayment     | -50.0  |
            | net_employment_income      | 325.0  |
