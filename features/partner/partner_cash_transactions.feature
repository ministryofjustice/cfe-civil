Feature:
  "Partner with cash transactions"

  Scenario: An applicant with a partner who has cash transactions
    Given I am undertaking a certificated assessment
    And I add the following "rent_or_mortgage" cash_transaction "outgoings" details for the partner:
      | client_id |    amount     | date         |
      | bill      |   234.00      | 2022-02-01   |
      | bill      |   234.00      | 2022-04-01   |
      | bill      |   234.00      | 2022-03-01   |
    When I retrieve the final assessment
    Then I should see the following "partner_disposable_income_all_sources" details:
      | attribute               | value      |
      | rent_or_mortgage        | 234.0      |

