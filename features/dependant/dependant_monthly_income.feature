Feature:
  "Dependents with monthly income"

  Scenario: Dependant has non-zero monthly income below the allowance threshold
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 100            |
      | 2004-06-11    | FALSE                  | child_relative | 100            |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 207.64  |
      | dependant allowance over 16       | 207.64  |

  Scenario:   Scenario: Dependant has non-zero monthly income that exceeds allowance threshold
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 400            |
      | 2004-06-11    | FALSE                  | child_relative | 400            |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 0.0     |
      | dependant allowance over 16       | 0.0     |
