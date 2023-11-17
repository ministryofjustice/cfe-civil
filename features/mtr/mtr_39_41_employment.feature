Feature:
    "Employment"

    Scenario: The client is employed, and receiving a prisoner_levy
        Given I am undertaking a certificated assessment
        And A submission date of "2023-01-10"
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
      And I add the following employment details:
        | client_id |     date     |  gross | benefits_in_kind | tax    | national_insurance  | prisoner_levy |
        |     C     |  2022-06-22  | 500.00 |      0           | -55.00 |       -25.0         |     -20.0     |
        |     C     |  2022-07-22  | 500.00 |      0           | -55.00 |       -25.0         |     -20.0     |
        |     C     |  2022-08-22  | 500.00 |      0           | -55.00 |       -25.0         |     -20.0     |
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value  |
            | gross_income               | 500.0  |
            | fixed_employment_deduction | -45.0  |
            | tax                        | -55.0  |
            | national_insurance         | -25.0  |
            | prisoner_levy              | -20.0  |
            | net_employment_income      | 355.0  |