Feature:
    "child uplift when > 4 children"

    Scenario: 4 children
      Given I am undertaking a certificated assessment
      And I add the following dependent details for the current assessment:
        | date_of_birth | in_full_time_education | relationship   |
        | 2018-12-20    | FALSE                  | child_relative |
        | 2018-12-20    | FALSE                  | child_relative |
        | 2018-12-20    | FALSE                  | child_relative |
        | 2018-12-20    | FALSE                  | child_relative |
      When I retrieve the final assessment
      And I should see the following overall summary:
        | attribute                      | value    |
        | gross_income_upper_threshold_0 | 2657.0   |

  Scenario: 5 children
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
      | 2018-12-20    | FALSE                  | child_relative |
      | 2018-12-20    | FALSE                  | child_relative |
      | 2018-12-20    | FALSE                  | child_relative |
      | 2018-12-20    | FALSE                  | child_relative |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | gross_income_upper_threshold_0 | 2879.0   |
