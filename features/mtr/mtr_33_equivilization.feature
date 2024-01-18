Feature:
  "Threshold uplifts due to dependants under/over 14"

  Scenario: 1 dependant under 14
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2515-02-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 3786.25  |

  Scenario: 1 dependant over 14
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2500-02-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 4368.75  |

  Scenario: 1 dependants under 14, 1 over 14
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2515-02-11    | FALSE                  | child_relative |
      | 2500-02-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 5242.5  |


