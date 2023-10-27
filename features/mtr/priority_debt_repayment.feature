Feature:
  "Priority Debt Repayment"

  Scenario: The client is employed, Priority Debt Repayment is submitted as Cash transactions (Before MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" cash_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          |   0.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |   0.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   |  45.0  |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, Priority Debt Repayment is submitted as Cash transactions (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" cash_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 100.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |

  Scenario: The client is employed, Priority Debt Repayment is submitted as Outgoings (Before MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" outgoings of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   |  45.0  |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, Priority Debt Repayment is submitted as Outgoings (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" outgoings of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 100.0  |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 0.0    |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |


  Scenario: The client is employed, Priority Debt Repayment is submitted as Regular transactions (Before MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" regular_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          |  0.0   |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   |  45.0  |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, Priority Debt Repayment is submitted as Regular transactions (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-20"
    And I add employment income of 1200 per month
    And I add "priority_debt_repayment" regular_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                        | value  |
      | priority_debt_repayment          | 0.0    |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |
