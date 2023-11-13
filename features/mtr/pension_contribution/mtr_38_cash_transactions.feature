Feature:
  "Pension Contribution Threshold (Cash transactions)"

  Scenario: Case before MTR data, when pension contribution is not applied
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-01"
    And I add employment income of 1200 per month
    And I add "pension_contribution" cash_transactions of 70 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | pension_contribution      | 0.0    |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 0.0    |

  Scenario: Case after MTR data, when pension contribution applied is greater than 5% of the total gross income
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 1200 per month
    And I add "pension_contribution" cash_transactions of 70 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | pension_contribution      | 60.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 60.0   |


  Scenario: Case after MTR data, when pension contribution applied is less than 5% of the total gross income
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 1200 per month
    And I add "pension_contribution" cash_transactions of 50 per month
    When I retrieve the final assessment
    Then I should see the following "disposable_income_all_sources" details:
      | attribute                 | value  |
      | pension_contribution      | 50.0   |
    Then I should see the following "disposable_income_bank_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 0.0    |
    Then I should see the following "disposable_income_cash_transactions" details:
      | attribute                 | value  |
      | pension_contribution      | 50.0   |
