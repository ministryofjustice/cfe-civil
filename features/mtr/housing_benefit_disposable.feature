Feature:
  "Housing Benefit treated as gross income after MTR"

  Scenario: Housing benefit below the threshold, and ignored in disposable section
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And I add employment income of 2800 per month
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | client_id | amount  | housing_cost_type |
      | 2020-02-29   | og-id1    | 2500.00 | rent              |
      | 2020-03-27   | og-id2    | 2500.00 | rent              |
      | 2020-04-26   | og-id3    | 2500.00 | rent              |
    And I add housing benefit of 50 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible   |
      | gross housing costs          | 2500.0     |
      | net housing costs            | 2500.0     |
