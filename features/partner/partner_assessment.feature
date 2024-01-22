Feature:
  "Applicant has a partner"

  Scenario: An applicant with a partner who has additional property (capital)
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And A domestic abuse case
    And I add a disputed main property of value 150000 and mortgage 145000
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 170000.00 |
      | outstanding_mortgage        | 100000.00 |
      | percentage_owned            | 100       |
      | shared_with_housing_assoc   | false     |
      | subject_matter_of_dispute   | false     |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 150000.0 |
      | net_equity                 |    500.0 |
      | smod_allowance             |    500.0 |
      | main_home_equity_disregard |      0.0 |
      | transaction_allowance      |   4500.0 |
      | assessed_equity            |      0.0 |
      | subject_matter_of_dispute  |   true   |
    And I should see the following "partner property" details for the partner:
      | attribute                  | value     |
      | value                      | 170000.0  |
      | outstanding_mortgage       | 100000.0  |
      | percentage_owned           | 100.0     |
      | shared_with_housing_assoc  | false     |
      | assessed_equity            | 64900.0   |
      | net_value                  | 64900.0   |
      | subject_matter_of_dispute  |   false   |
    And I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |

Scenario: An applicant and partner's combined capital is over the lower threshold
  Given I am undertaking a certificated assessment
  And An applicant who receives passporting benefits
  And I add 2000 capital of type "bank_accounts"
  And I add the following capital details for "bank_accounts" for the partner:
    | description  | value   |
    | Bank account | 2000.0  |
  When I retrieve the final assessment
  And I should see the following overall summary:
    | attribute                    | value                 |
    | assessment_result            | contribution_required |
    | capital contribution         | 1000.0                |

  Scenario: An unemployed applicant with an employed partner
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add partner employment income of 590 per month
    When I retrieve the final assessment
    Then I should see the following "overall_disposable_income" details:
      | attribute                        | value   |
      | total_disposable_income          | 545.0   |
    And I should see the following "disposable_income_summary" details:
      | attribute                        | value   |
      | combined_total_disposable_income | 353.59  |
    And I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | contribution_required |
      | income contribution        | 14.91                 |
      | capital contribution       | 0.0                   |

  Scenario: A applicant with a partner with capital and both pensioners
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add partner employment income of 590 per month
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 170000.00 |
      | outstanding_mortgage        | 100000.00 |
      | percentage_owned            | 100       |
      | shared_with_housing_assoc   | false     |
      | subject_matter_of_dispute   | false     |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | ineligible            |
      | income contribution        | 14.91                 |
      | capital contribution       | 61900.0               |

  Scenario: A applicant with housing benefit and a partner with housing costs
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A domestic abuse case
    And I add housing benefit of 500 per month
    And I add "rent_or_mortgage" partner regular_transactions of 600 per month
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | partner allowance              | 191.41   |
      | total outgoings and allowances | 291.41   |

  Scenario: An applicant with an employed partner who is over the gross income threshold
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add partner employment income of 5090 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | ineligible            |

  Scenario: A partner case on or after 10th April 2023
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-10"
    And I have a dependant aged 2
    And I add the following capital details for "bank_accounts" for the partner:
      | description  | value   |
      | Bank account | 2000.0  |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | partner allowance              | 211.32   |
      | dependant allowance            | 338.9    |
