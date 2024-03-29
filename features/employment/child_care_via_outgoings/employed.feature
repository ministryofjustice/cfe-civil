Feature:
  "Child care entitlement via outgoings(employed)"

  Scenario: The client is employed, child care submitted as outgoings, gross income > 0
    Given I am undertaking a certificated assessment
    And I add employment income of 500 per month
    And I have a dependant aged 13
    And I add outgoing details for "child_care" of 200 per month
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 200.0  |

  Scenario: The client is employed, child care submitted as outgoings, gross income = 0
    Given I am undertaking a certificated assessment
    And I add employment income of 0 per month
    And I have a dependant aged 13
    And I add outgoing details for "child_care" of 200 per month
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 0.0    |

