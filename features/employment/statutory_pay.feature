Feature:
    "Statutory pay"

    Scenario: The client is receiving statutory sick pay only
        Given I am undertaking a certificated assessment
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
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
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
            | employed                    | true       |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
        And I add the following statutory sick pay details for the client:
            | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
            |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
        And I add the following outgoing details for "child_care" in the current assessment:
            | payment_date | client_id | amount |
            | 2020-02-29   | og-id1    | 200.00 |
            | 2020-03-27   | og-id2    | 200.00 |
            | 2020-04-26   | og-id3    | 200.00 |
        And I add the following dependent details for the current assessment:
            | date_of_birth | in_full_time_education | relationship   |
            | 2018-12-20    | FALSE                  | child_relative |
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The client is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
            | employed                    | true       |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
        And I add the following "client" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind | tax  | national_insurance  | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
        And I add the following outgoing details for "child_care" in the current assessment:
            | payment_date | client_id | amount |
            | 2020-02-29   | og-id1    | 200.00 |
            | 2020-03-27   | og-id2    | 200.00 |
            | 2020-04-26   | og-id3    | 200.00 |
        And I add the following dependent details for the current assessment:
            | date_of_birth | in_full_time_education | relationship   |
            | 2018-12-20    | FALSE                  | child_relative |
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

    Scenario: The partner is receiving statutory sick pay, input via the newer "employment_details" section, but has entered childcare costs
        Given I am undertaking a certificated assessment
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
            | employed                    | true       |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
        And I add the following "client" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind | tax  | national_insurance  | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 600.00  | 0                |  -50 | -30                 | false                                           |
        And I add the following "partner" employment details in the current assessment:
            | frequency | gross    | benefits_in_kind |  tax | national_insurance | receiving_only_statutory_sick_or_maternity_pay |
            | monthly   | 600.00  | 0                |  -50 | -30                | true                                           |
        And I add the following outgoing details for "child_care" in the current assessment:
            | payment_date | client_id | amount |
            | 2020-02-29   | og-id1    | 200.00 |
            | 2020-03-27   | og-id2    | 200.00 |
            | 2020-04-26   | og-id3    | 200.00 |
        And I add the following dependent details for the current assessment:
            | date_of_birth | in_full_time_education | relationship   |
            | 2018-12-20    | FALSE                  | child_relative |
        When I retrieve the final assessment
        Then I should see the following "disposable income" details:
            | attribute                      | value      |
            | childcare_allowance            | 0.0        |

