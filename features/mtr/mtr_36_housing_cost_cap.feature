Feature:
  "Housing Cost Cap"

  Scenario: The housing cost cap is applied
    Given I am undertaking a certificated assessment
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 1200.00 | rent              |
      | 2020-03-27   | og-id2    | 1200.00 | rent              |
      | 2020-04-26   | og-id3    | 1200.00 | rent              |
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
    And A submission date post-mtr
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 1200.00 | rent              |
      | 2020-03-27   | og-id2    | 1200.00 | rent              |
      | 2020-04-26   | og-id3    | 1200.00 | rent              |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value   |
      | gross housing costs            | 1200.0  |
      | net housing costs              | 1200.0  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |  1200.0  |
      | total_disposable_income        | -1200.0  |
