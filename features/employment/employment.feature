Feature:
    "Employment"

    Scenario: The client is employed, and receiving a benefit in kind
        Given I am undertaking a certificated assessment
        And I add employment income of 500 per month with 100 benefits_in_kind, 55 tax and 25 national insurance
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value  |
            | gross_income               | 500.0  |
            | benefits_in_kind           | 100.0  |
            | fixed_employment_deduction | -45.0  |
            | tax                        | -55.0  |
            | national_insurance         | -25.0  |
            | net_employment_income      | 475.0  |
