Feature:
  "Housing Cost Cap"

  Scenario: The housing cost cap is applied
    Given I am undertaking a certificated assessment
    And I add outgoing details for "rent_or_mortgage" of 1200 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value   |
      | net housing costs              |  545.0  |
      | gross housing costs            | 1200.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | total_outgoings_and_allowances |  545.0  |
      | total_disposable_income        | -545.0  |

  Scenario: The housing cost cap is removed under MTR rules
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add outgoing details for "rent_or_mortgage" of 1200 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value   |
      | gross housing costs            | 1200.0  |
      | net housing costs              | 1200.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |  1200.0  |
      | total_disposable_income        | -1200.0  |
