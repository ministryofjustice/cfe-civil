Feature:
    "Statutory pay"

    Scenario: The client is receiving statutory sick pay only
        Given I am undertaking a certificated assessment
        And I add the following statutory sick pay details for the client:
            | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
            |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value    |
            | fixed_employment_deduction | 0.0      |

    Scenario: The client is receiving statutory sick pay only but has entered childcare costs
        Given I am undertaking a certificated assessment
        And I add the following statutory sick pay details for the client:
            | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
            |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
        And I add outgoing details for "child_care" of 200 per month
        And I have 1 dependant children
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The client is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And I add the following "client" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind | tax  | national_insurance  | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
        And I add outgoing details for "child_care" of 200 per month
        And I have 1 dependant children
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The partner is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And I add the following "client" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind | tax  | national_insurance  | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 600.00  | 0                |  -50 | -30                 | false                                           |
        And I add the following "partner" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind |  tax | national_insurance | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 600.00  | 0                |  -50 | -30                | true                                           |
        And I add outgoing details for "child_care" of 200 per month
        And I have 1 dependant children
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |
