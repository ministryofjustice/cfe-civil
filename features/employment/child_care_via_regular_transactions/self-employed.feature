Feature:
  "Child care entitlement via regular transactions(self-employed)"

  Scenario: The client is self-employed, child care submitted as regular_transactions, gross > 0
    Given I am undertaking a certificated assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    And I add "child_care" regular_transactions of 200 per month
    And I have 1 dependant children
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 200.0      |

  Scenario: The client is self-employed, child care submitted as regular_transactions, gross = 0
    Given I am undertaking a certificated assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 0.00     |  0   |  0                  |
    And I add "child_care" regular_transactions of 200 per month
    And I have 1 dependant children
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 0.0        |

