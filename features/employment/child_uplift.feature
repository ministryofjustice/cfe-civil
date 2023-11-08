Feature:
    "child uplift when > 4 children"

    Scenario: 4 children
      Given I am using version 6 of the API
      And I am undertaking a certificated assessment
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
    Given I am using version 6 of the API
    And I am undertaking a certificated assessment
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

  Scenario: 5 children with 1 earning more than threshold
    Given I am using version 6 of the API
    And I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2018-12-20    | FALSE                  | child_relative |      340      | monthly          |
      | 2018-12-20    | FALSE                  | child_relative |        0      | monthly          |
      | 2018-12-20    | FALSE                  | child_relative |        0      | monthly          |
      | 2018-12-20    | FALSE                  | child_relative |        0      | monthly          |
      | 2018-12-20    | FALSE                  | child_relative |        0      | monthly          |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | gross_income_upper_threshold_0 | 2657.0   |
