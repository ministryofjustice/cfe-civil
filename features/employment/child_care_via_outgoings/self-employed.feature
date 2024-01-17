Feature:
  "Child care entitlement via outgoings(self-employed)"

  Scenario: The client is employed, child care submitted as outgoings, gross income > 0
    Given I am undertaking a certificated assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 500.00   |   0  |  0                  |
    And I have 1 dependant children
    And I add outgoing details for "child_care" of 200 per month
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 200.0  |

  Scenario: The client is employed, child care submitted as outgoings, gross income = 0
    Given I am undertaking a certificated assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 0        |   0  |  0                  |
    And I have 1 dependant children
    And I add outgoing details for "child_care" of 200 per month
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 0.0    |

