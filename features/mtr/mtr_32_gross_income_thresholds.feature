Feature:
  "Gross income Thresholds"

  Scenario: Gross income without lower threshold before MTR
    Given I am undertaking a controlled assessment
    And A submission date of "2023-04-10"
    And I add employment income of 400 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | eligible   |
      | gross_income_upper_threshold_0 | 2657.0     |
      | gross_income_lower_threshold_0 | 0.0        |

  Scenario: Gross income with lower threshold after MTR
    Given I am undertaking a controlled assessment
    And A submission date of "2525-04-10"
    And I add employment income of 400 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | eligible   |
      | gross_income_upper_threshold_0 | 2912.5     |
      | gross_income_lower_threshold_0 | 946.0      |
