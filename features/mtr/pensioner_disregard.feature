Feature:
  "MTR Pensioner Disregards"

  Scenario: Non-passported pensioner with large disposable income
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2525-04-10"
    And I add employment income of 400 per month
    And I add the following main property details for the current assessment:
      | value                     | 250000 |
      | outstanding_mortgage      |  16000 |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | contribution_required |
    And I should see the following "capital summary" details:
      | attribute                     | value   |
      | total_capital                 | 41500.0 |
      | pensioner_capital_disregard   | 65000.0 |
      | assessed_capital              | 0.0     |
      | pensioner_disregard_applied   | 41500.0 |

