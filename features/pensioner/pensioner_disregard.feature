Feature:
  "Applicant is a pensioner"

  Scenario: An applicant over 60 with enough disposable income to reduce the pensioner disregard
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add employment income of 1000 per month
    And I add outgoing details for "maintenance_out" of 550 per month
    And I add a non-disputed main property of value 140000 and mortgage 16000
    And I add the following capital details for "bank_accounts" for the partner:
      | description  | value   |
      | Bank account | 2000.0  |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 140000.0 |
      | main_home_equity_disregard | 100000.0 |
      | transaction_allowance      | 4200.0   |
    And I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
      | capital_lower_threshold      | 3000.0   |
    And I should see the following "capital summary" details:
      | attribute                     | value   |
      | total_capital                 | 19800.0 |
      | pensioner_capital_disregard   | 20000.0 |
      | assessed_capital              | 0.0     |
      | pensioner_disregard_applied   | 19800.0 |

  Scenario: A pensioner applicant with a partner - pensioner disregard applies across combined capital
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add employment income of 300 per month
    And I add the following capital details for "non_liquid_capital" in the current assessment:
      | description    | value   | subject_matter_of_dispute |
      | Investment     | 10000.0 | false                     |
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 170000.00 |
      | outstanding_mortgage        | 100000.00 |
      | percentage_owned            | 100       |
      | shared_with_housing_assoc   | false     |
      | subject_matter_of_dispute   | false     |
    When I retrieve the final assessment
    Then I should see the following "partner property" details for the partner:
      | attribute                   | value    |
      | value                       | 170000.0 |
      | transaction_allowance       | 5100.0   |
      | net_value                   | 64900.0  |
      | net_equity                  | 64900.0  |
      | assessed_equity             | 64900.0  |
      | subject_matter_of_dispute   |   false  |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_capital               | 10000.0  |
      | pensioner_capital_disregard | 80000.0  |
      | assessed_capital            | 0.0      |
      | pensioner_disregard_applied | 10000.0  |
    Then I should see the following "partner capital summary" details:
      | attribute                   | value    |
      | total_capital               | 64900.0  |
      | assessed_capital            | 0.0      |
      | pensioner_disregard_applied | 64900.0  |
    And I should see the following overall summary:
      | attribute                   | value    |
      | assessment_result           | eligible |
      | combined_assessed_capital   | 0.0      |
