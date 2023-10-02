Feature:
  "Housing Benefit treated as gross income after MTR"

  Scenario: Housing benefit pre MTR - have to add a dependant to avoid the housing cap
    Given I am undertaking a certificated assessment
    And A submission date of "2022-04-10"
    And I add employment income of 1800 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-04-29   | og-id1    | 1100.00 | rent              |
      | 2020-05-29   | og-id2    | 1100.00 | rent              |
      | 2020-06-29   | og-id3    | 1100.00 | rent              |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2015-02-11    | FALSE                  | child_relative |
    And I add housing benefit of 50 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
      | gross_income_upper_threshold_0 | 2657.0                |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 1800.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value                 |
      | total_disposable_income        | 406.92                |

  Scenario: Housing benefit causes gross income threshold to be exceeded
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 2900 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2500.00 | rent              |
      | 2020-03-27   | og-id2    | 2500.00 | rent              |
      | 2020-04-26   | og-id3    | 2500.00 | rent              |
    And I add housing benefit of 50 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | ineligible            |
      | gross_income_upper_threshold_0 | 2912.5                |
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 2950.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value                 |
      | total_disposable_income        | 0.0                   |
