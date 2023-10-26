Feature:
  "Housing Benefit treated as gross income after MTR"

  Scenario: Housing benefit pre MTR is disposable income
    Given I am undertaking a certificated assessment
    And A submission date of "2023-04-10"
    And I add partner employment income of 2600 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2200.00 | rent              |
      | 2020-03-27   | og-id2    | 2200.00 | rent              |
      | 2020-04-26   | og-id3    | 2200.00 | rent              |
    And I add housing benefit of 350 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
      | gross_income_upper_threshold_0 | 2657.0                |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 2600.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                         | value        |
      | combined_total_disposable_income  | 493.68       |

  Scenario: Housing benefit causes gross income threshold to be exceeded
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 2600 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2200.00 | rent              |
      | 2020-03-27   | og-id2    | 2200.00 | rent              |
      | 2020-04-26   | og-id3    | 2200.00 | rent              |
    And I add housing benefit of 350 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | ineligible            |
      | gross_income_upper_threshold_0 | 2912.5                |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 2950.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                        | value                |
      | combined_total_disposable_income |   0.0                |
