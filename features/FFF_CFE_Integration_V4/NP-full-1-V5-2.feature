Feature:
    "1. Fully eligible, 2. No contribution"

    Scenario: Test that the correct output is produced for the following set of data.
        Given I am undertaking a certificated assessment
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | DA001     | A                       |
            | SE013     | A                       |
            | SE003     | A                       |
        And I have 1 dependant children
        And I add other income "friends_or_family" of 100 per month
        And I add the following irregular_income details in the current assessment:
            | income_type  | frequency | amount |
            | student_loan | annual    | 120.00 |
        And I add outgoing details for "rent_or_mortgage" of 10 per month
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description | value  |
            | Bank acc 1  | 4999.0 |
            | Bank acc 2  | 0      |
            | Bank acc 3  | 0      |
        When I retrieve the final assessment

        Then I should see the following overall summary:
            | attribute                      | value    |
            | assessment_result              | contribution_required |
            | capital_lower_threshold        | 3000.0   |
            | gross_income_upper_threshold_1 | 2657.0   |

        Then I should see the following "gross_income_proceeding_types" details where "ccms_code:SE013":
            | attribute               | value    |
            | client_involvement_type | A        |
            | upper_threshold         | 2657.0   |
            | lower_threshold         | 0.0      |
            | result                  | eligible |
