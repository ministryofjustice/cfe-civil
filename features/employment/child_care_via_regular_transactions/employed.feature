Feature:
  "Child care entitlement via regular transactions(employed)"

  Scenario: The client is receiving statutory sick pay only
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2
    And I add "child_care" regular_transactions of 200 per month
    And I add the following statutory sick pay details for the client:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
      |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
      |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
      |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
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
