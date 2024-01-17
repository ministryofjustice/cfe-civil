Feature:
  "MTR Pensioner Disregards"

  Scenario: Non-passported pensioner with highest capital disregard (100k)
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2525-04-10"
    And I add employment income of 270 per month
    And I add a non-disputed main property of value 250000 and mortgage 36000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  204.0  |
      | income_contribution     |  0.0    |
    And I should see the following "capital summary" details:
      | attribute                     | value    |
      | total_capital                 | 21500.0  |
      | pensioner_capital_disregard   | 100000.0 |
      | assessed_capital              | 0.0      |
      | pensioner_disregard_applied   | 21500.0  |

  Scenario: Non-passported pensioner with second highest capital disregard (65k)
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2525-04-10"
    And I add employment income of 280 per month
    And I add a non-disputed main property of value 250000 and mortgage 16000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  214.0  |
      | income_contribution     |  0.0    |
    And I should see the following "capital summary" details:
      | attribute                     | value   |
      | total_capital                 | 41500.0 |
      | pensioner_capital_disregard   | 65000.0 |
      | assessed_capital              | 0.0     |
      | pensioner_disregard_applied   | 41500.0 |

  Scenario: Non-passported pensioner with third highest capital disregard (35k)
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2525-04-10"
    And I add employment income of 485 per month
    And I add a non-disputed main property of value 250000 and mortgage 16000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  419.0  |
      | income_contribution     |  0.0    |
    And I should see the following "capital summary" details:
      | attribute                     | value   |
      | total_capital                 | 41500.0 |
      | pensioner_capital_disregard   | 35000.0 |
      | assessed_capital              |  6500.0 |
      | pensioner_disregard_applied   | 35000.0 |

  Scenario: Non-passported pensioner with zero capital disregard (0k)
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2525-04-10"
    And I add employment income of 695 per month
    And I add a non-disputed main property of value 250000 and mortgage 56000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  629.0  |
      | income_contribution     |  0.0    |
    And I should see the following "capital summary" details:
      | attribute                     | value   |
      | total_capital                 |  1500.0 |
      | pensioner_capital_disregard   |     0.0 |
      | assessed_capital              |  1500.0 |
      | pensioner_disregard_applied   |     0.0 |

