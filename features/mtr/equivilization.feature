Feature:
  "Threshold uplifts due to dependants under/over 14"

  Scenario: 2 dependants under 14, 3 over 14
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2515-02-11    | FALSE                  | child_relative |
      | 2515-02-11    | FALSE                  | child_relative |
      | 2500-02-11    | FALSE                  | child_relative |
      | 2500-02-11    | FALSE                  | child_relative |
      | 2500-02-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 9028.75  |

