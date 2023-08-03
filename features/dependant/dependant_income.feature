Feature:
  "Dependents with income(amount and frequency)"

  Scenario: Dependant has non-zero monthly income below the allowance threshold
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 100           | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 100           | monthly          |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 307.64  |
      | dependant allowance over 16       | 207.64  |

  Scenario: Dependant has non-zero monthly income that exceeds allowance threshold
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 400           | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 400           | monthly          |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 307.64  |
      | dependant allowance over 16       | 0  |

  Scenario: Dependant has non-zero weekly income that exceeds allowance threshold
    Given I am undertaking a certificated assessment
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 200           | weekly           |
      | 2004-06-11    | FALSE                  | child_relative | 200           | weekly           |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 307.64  |
      | dependant allowance over 16       | 0       |

