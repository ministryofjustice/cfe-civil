Feature:
    "child uplift when > 4 children"

    Scenario: 4 children
      Given I am undertaking a certificated assessment
      And I have a dependant aged 2
      And I have a dependant aged 3
      And I have a dependant aged 4
      And I have a dependant aged 5
      When I retrieve the final assessment
      And I should see the following overall summary:
        | attribute                      | value    |
        | gross_income_upper_threshold_0 | 2657.0   |

  Scenario: 5 children
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2
    And I have a dependant aged 3
    And I have a dependant aged 4
    And I have a dependant aged 5
    And I have a dependant aged 6
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | gross_income_upper_threshold_0 | 2879.0   |

  Scenario: 5 children with 1 earning more than threshold
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2
    And I have a dependant aged 3
    And I have a dependant aged 4
    And I have a dependant aged 5
    And I have a dependant aged 6 with monthly income of 340
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | gross_income_upper_threshold_0 | 2657.0   |
