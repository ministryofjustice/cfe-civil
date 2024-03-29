Feature:
  "Applicant is applying under controlled work and has a property so costs of sale (transaction_allowance) are not included"

  Scenario: An applicant has property and sale costs are not disregarded
    Given I am undertaking a controlled assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed main property of value 163000 and mortgage 13000
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 163000.0 |
      | main_home_equity_disregard | 100000.0 |
      | transaction_allowance      | 0.0      |
      | assessed_equity            | 50000.0  |
      | subject_matter_of_dispute  |   false  |
    And I should see the following overall summary:
      | attribute                  | value      |
      | assessment_result          | ineligible |

