Feature:
    "I have a property that is disputed"

    Scenario: A SMOD property where the value of the client's share of its equity is entirely disregarded
        Given I am undertaking a standard assessment with an applicant who receives passporting benefits
        And I add the following main property details for the current assessment:
            | value                     | 150000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 150000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 4500.0   |
            | assessed_equity            | 45500.0  |
        And I should see the following "capital summary" details:
            | attribute                           | value   |
            | total_property                      | 45500.0 |
            | subject_matter_of_dispute_disregard | 45500.0 |
            | assessed_capital                    | 0.0     |

    Scenario: The SMOD disregard is capped if the property is assessed as being worth more than £100k.
        Given I am undertaking a standard assessment with an applicant who receives passporting benefits
        And I add the following main property details for the current assessment:
            | value                     | 250000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 250000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 7500.0   |
            | assessed_equity            | 142500.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_property                      | 142500.0 |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 42500.0  |

    Scenario: Disputed main and additional properties which, combined, are assessed as worth less than £100k
        Given I am undertaking a standard assessment with an applicant who receives passporting benefits
        And I add the following main property details for the current assessment:
            | value                     | 250000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 50     |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        And I add the following additional property details for the current assessment:
            | value                     | 50000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 250000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 7500.0   |
            | assessed_equity            | 21250.0  |
        Then I should see the following "additional property" details:
            | attribute                  | value   |
            | value                      | 50000.0 |
            | main_home_equity_disregard | 0.0     |
            | transaction_allowance      | 1500.0  |
            | assessed_equity            | 48500.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value   |
            | total_property                      | 69750.0 |
            | subject_matter_of_dispute_disregard | 69750.0 |
            | assessed_capital                    | 0.0     |
