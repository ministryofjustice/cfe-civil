Feature:
  "Council Tax"

  Scenario: The client is employed, council tax is submitted as Cash transactions (Before MTR)
    Given I am undertaking a certificated assessment
    And I add employment income of 1200 per month
    And I add "council_tax" cash_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 45.0   |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, council tax is submitted as Cash transactions (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 1200 per month
    And I add "council_tax" cash_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               | 100.0  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |

  Scenario: The client is employed, council tax is submitted as Outgoings (Before MTR)
    Given I am undertaking a certificated assessment
    And I add employment income of 1200 per month
    And I add "council_tax" outgoings of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   |  45.0  |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, council tax is submitted as Outgoings (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 1200 per month
    And I add "council_tax" outgoings of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               | 100.0  |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               | 0.0    |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |


  Scenario: The client is employed, council tax is submitted as Regular transactions (Before MTR)
    Given I am undertaking a certificated assessment
    And I add employment income of 1200 per month
    And I add "council_tax" regular_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               |  0.0   |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   |  45.0  |
      | total_disposable_income          | 1155.0 |

  Scenario: The client is employed, council tax is submitted as Regular transactions (After MTR)
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 1200 per month
    And I add "council_tax" regular_transactions of 100 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | council_tax               | 100.0  |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | council_tax               | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | council_tax               | 0.0    |
    Then I should see the following "disposable_income_summary" details:
      | attribute                        | value  |
      | total_outgoings_and_allowances   | 166.0  |
      | total_disposable_income          | 1034.0 |
