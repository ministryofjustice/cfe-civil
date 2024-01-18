Feature:
  "Dependant allowances including lone parent allowance"

  Scenario: Single with dependants
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add the following dependent details for the current assessment:
      | desc     | date_of_birth | in_full_time_education | relationship   |
      | under 14 | 2515-02-11    | FALSE                  | child_relative |
      | under 16 | 2510-02-11    | FALSE                  | child_relative |
      | adult    | 2500-06-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | dependant_allowance_under_16     | 659.0  |
      | dependant_allowance_over_16      | 448.0  |
      | lone_parent_allowance            | 313.6  |

  Scenario: Single without dependants
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    When I retrieve the final assessment
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | lone_parent_allowance            | 0      |

  Scenario: With a partner and dependants
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    And I add the following dependent details for the current assessment:
      | desc     | date_of_birth | in_full_time_education | relationship   |
      | under 14 | 2515-02-11    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | lone_parent_allowance            | 0      |
