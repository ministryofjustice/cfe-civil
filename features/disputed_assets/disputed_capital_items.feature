Feature:
    "I have a disputed capital items"

    Scenario: A SMOD bank account whose value is entirely disregarded
        Given I am undertaking a certificated assessment
        And An applicant who receives passporting benefits
        And I add 5000 disputed capital of type "bank_accounts"
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value  |
            | total_liquid                        | 5000.0 |
            | subject_matter_of_dispute_disregard | 5000.0 |
            | assessed_capital                    | 0.0    |

    Scenario: A SMOD investment whose value is entirely disregarded
        Given I am undertaking a certificated assessment
        And An applicant who receives passporting benefits
        And I add 50000 disputed capital of type "non_liquid_capital"
        And I add 25000 capital of type "non_liquid_capital"
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value   |
            | total_non_liquid                    | 75000.0 |
            | subject_matter_of_dispute_disregard | 50000.0 |
            | assessed_capital                    | 25000.0 |

    Scenario: A SMOD bank account whose value is over the SMOD disregard limit
        Given I am undertaking a certificated assessment
        And An applicant who receives passporting benefits
        And I add 150000 disputed capital of type "bank_accounts"
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_liquid                        | 150000.0 |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 50000.0  |

    Scenario: Two SMOD assets whose combined value is over the SMOD disregard limit
        Given I am undertaking a certificated assessment
        And An applicant who receives passporting benefits
        And I add 50000 disputed capital of type "bank_accounts"
        And I add 60000 disputed capital of type "non_liquid_capital"
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_liquid                        | 50000.0  |
            | total_non_liquid                    | 60000.0  |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 10000.0  |
