Feature:
  "Partner with other incomes"

  Scenario: An applicant with a partner who has other income
    Given I am undertaking a certificated assessment
    And I add the following "friends_or_family" other income details for the partner:
      | client_id |    amount     | date         |
      | bill      |   234.00      | 2022-02-01   |
      | bill      |   234.00      | 2022-04-01   |
      | bill      |   234.00      | 2022-03-01   |
    When I retrieve the final assessment
    Then I should see the following "partner_other_income_all_sources" details:
      | attribute               | value      |
      | friends_or_family       | 234.0      |
