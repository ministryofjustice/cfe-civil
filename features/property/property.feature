Feature:
  "I have a property"

  Scenario: A property where the main home equity is smaller than the capped disregard figure
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 50 percent share main property of value 150000 and mortgage 100000
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 150000.0 |
      | transaction_allowance      |   4500.0 |
      | net_value                  |  45500.0 |
      | net_equity                 |  22750.0 |
      | main_home_equity_disregard |  22750.0 |
      | assessed_equity            |      0.0 |
      | subject_matter_of_dispute  |   false  |
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | total_property             |      0.0 |
      | assessed_capital           |      0.0 |
