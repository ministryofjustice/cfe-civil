Feature:
  "Dependant allowances including lone parent allowance"

  Scenario: Single with dependants
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I have a dependant aged 13
    And I have a dependant aged 15
    And I have a dependant aged 20
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
    And The "partner" earns 1200 per month
    And I have a dependant aged 13
    When I retrieve the final assessment
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | lone_parent_allowance            | 0      |
