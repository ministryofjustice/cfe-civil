Feature:
  "Threshold uplifts due to dependants under/over 14"

  Scenario: 1 dependant under 14
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I have a dependant aged 2
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 3786.25  |

  Scenario: 1 dependant over 14
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I have a dependant aged 15
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 4368.75  |

  Scenario: 1 dependants under 14, 1 over 14
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I have a dependant aged 2
    And I have a dependant aged 15
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 5242.5  |


