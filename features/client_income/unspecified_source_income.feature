Feature:
    "I have income from unspecified sources to declare in my assessment"

    Scenario: Test that the correct output is produced for the following set of data.
        Given I am undertaking a certificated assessment
        And I add the following irregular_income details in the current assessment:
            | income_type               | frequency    | amount |
            | unspecified_source        | quarterly    | 336.33 |
        When I retrieve the final assessment
        Then I should see the following "disposable_income_summary" details:
            | attribute               | value    |
            | total_disposable_income | 112.11   |
