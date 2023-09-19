Feature:
  "Dependant allowances"

  Scenario: With some dependants
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add the following dependent details for the current assessment:
      | desc     | date_of_birth | in_full_time_education | relationship   |
      | under 14 | 2515-02-11    | FALSE                  | child_relative |
      | under 16 | 2510-02-11    | FALSE                  | child_relative |
      | adult    | 2500-06-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value  |
      | dependant allowance under 16      | 659.0  |
      | dependant allowance over 16       | 448.0  |
