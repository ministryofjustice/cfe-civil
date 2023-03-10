Feature:
    "I submit controlled assessments and see appropriate thresholds"

    Scenario: Gross income is below threshold (and so is disposable income)
        Given I am undertaking a controlled assessment
        And I add the following other_income details for "friends_or_family" in the current assessment:
            | date       | client_id | amount  |
            | 2021-05-10 | id3       | 2600.00 |
            | 2021-04-10 | id2       | 2600.00 |
            | 2021-03-10 | id3       | 2600.00 |
        And I add the following outgoing details for "maintenance_out" in the current assessment:
            | payment_date | housing_cost_type | client_id | amount   |
            | 2021-05-10   | rent              | id7       | 2500.00  |
            | 2021-04-10   | rent              | id8       | 2500.00  |
            | 2021-03-10   | rent              | id9       | 2500.00  |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value    |
            | assessment_result            | eligible |

    Scenario: Gross income is above threshold (but disposable income is under it)
        Given I am undertaking a controlled assessment
        And I add the following other_income details for "friends_or_family" in the current assessment:
            | date       | client_id | amount  |
            | 2021-05-10 | id3       | 2700.00|
            | 2021-04-10 | id2       | 2700.00 |
            | 2021-03-10 | id3       | 2700.00 |
        And I add the following outgoing details for "maintenance_out" in the current assessment:
            | payment_date | housing_cost_type | client_id | amount   |
            | 2021-05-10   | rent              | id7       | 2600.00  |
            | 2021-04-10   | rent              | id8       | 2600.00  |
            | 2021-03-10   | rent              | id9       | 2600.00  |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value      |
            | assessment_result            | ineligible |

    Scenario: Disposable income is below threshold
        Given I am undertaking a controlled assessment
        And I add the following other_income details for "friends_or_family" in the current assessment:
            | date       | client_id | amount  |
            | 2021-05-10 | id3       | 1000.00 |
            | 2021-04-10 | id2       | 1000.00 |
            | 2021-03-10 | id3       | 1000.00 |
        And I add the following outgoing details for "maintenance_out" in the current assessment:
            | payment_date | housing_cost_type | client_id | amount  |
            | 2021-05-10   | rent              | id7       | 300.00  |
            | 2021-04-10   | rent              | id8       | 300.00  |
            | 2021-03-10   | rent              | id9       | 300.00  |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value    |
            | assessment_result            | eligible |

    Scenario: Disposable income is above threshold
        Given I am undertaking a controlled assessment
        And I add the following other_income details for "friends_or_family" in the current assessment:
            | date       | client_id | amount  |
            | 2021-05-10 | id3       | 1000.00 |
            | 2021-04-10 | id2       | 1000.00 |
            | 2021-03-10 | id3       | 1000.00 |
        And I add the following outgoing details for "maintenance_out" in the current assessment:
            | payment_date | housing_cost_type | client_id | amount  |
            | 2021-05-10   | rent              | id7       | 200.00  |
            | 2021-04-10   | rent              | id8       | 200.00  |
            | 2021-03-10   | rent              | id9       | 200.00  |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value      |
            | assessment_result            | ineligible |

    Scenario: Capital is below threshold
        Given I am undertaking a controlled assessment
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description  | value   | subject_matter_of_dispute |
            | Bank account | 7000.0  | false                     |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value    |
            | assessment_result            | eligible |

    Scenario: Capital is above threshold
        Given I am undertaking a controlled assessment
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description  | value   | subject_matter_of_dispute |
            | Bank account | 9000.0  | false                     |
        When I retrieve the final assessment
        Then I should see the following overall summary:
            | attribute                    | value      |
            | assessment_result            | ineligible |
