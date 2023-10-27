Feature:
  "Housing Benefit treated as gross income after MTR"

  Scenario: pre-MTR - Housing benefit treated as disposable income
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-10"
    And I add partner employment income of 2600 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2300.00 | rent              |
      | 2020-03-27   | og-id2    | 2300.00 | rent              |
      | 2020-04-26   | og-id3    | 2300.00 | rent              |
    And I add housing benefit of 250 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible   |
      | gross housing costs          | 2300.0     |
      | net housing costs            | 2050.0     |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 2600.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                        |  value   |
      | combined_total_disposable_income |  293.68  |

  Scenario: Post MTR - Housing benefit in gross income not disposable
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add partner employment income of 2600 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2300.00 | rent              |
      | 2020-03-27   | og-id2    | 2300.00 | rent              |
      | 2020-04-26   | og-id3    | 2300.00 | rent              |
    And I add housing benefit of 250 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible   |
      | gross housing costs          | 2300.0     |
      | net housing costs            | 2300.0     |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 2850.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                        | value    |
      | combined_total_disposable_income |  272.68  |
