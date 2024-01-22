Feature:
    "Statutory pay"

    Scenario: The client is receiving statutory sick pay only
        Given I am undertaking a certificated assessment
        And The "client" earns 500 per month in statutory sick pay
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value    |
            | fixed_employment_deduction | 0.0      |

    Scenario: The client is receiving statutory sick pay only but has entered childcare costs
        Given I am undertaking a certificated assessment
        And The "client" earns 500 per month in statutory sick pay
        And I have a dependant aged 2
        And I add outgoing details for "child_care" of 200 per month
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The client is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And The "client" earns 1200 per month in statutory sick pay
        And I have a dependant aged 2
        And I add outgoing details for "child_care" of 200 per month
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The partner is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And The "client" earns 600 per month
        And The "partner" earns 600 per month in statutory sick pay
        And I have a dependant aged 2
        And I add outgoing details for "child_care" of 200 per month
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |
