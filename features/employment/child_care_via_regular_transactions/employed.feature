Feature:
  "Child care entitlement via regular transactions(employed)"

  Scenario: The client is receiving statutory sick pay only
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2
    And I add "child_care" regular_transactions of 200 per month
    And The "client" earns 500 per month in statatory sick pay
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                 | value  |
      | childcare_allowance       | 0.0    |

  Scenario: The client is employed, child care submitted as regular_transactions, gross income > 0
    Given I am undertaking a certificated assessment
    And I add employment income of 500 per month
    And I add "child_care" regular_transactions of 200 per month
    And I have a dependant aged 2
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 200.0      |

  Scenario: The client is employed, child care submitted as regular_transactions, gross = 0
    Given I am undertaking a certificated assessment
    And I add employment income of 0 per month
    And I add "child_care" regular_transactions of 200 per month
    And I have a dependant aged 2
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 0.0        |
