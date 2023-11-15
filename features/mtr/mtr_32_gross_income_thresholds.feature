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

  Scenario: Post MTR - Gross income with lower threshold skips disposable test
    Given I am undertaking a controlled assessment
    And A submission date of "2525-04-10"
    And I add employment income of 945 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | eligible   |
      | gross_income_upper_threshold_0 | 2912.5     |
      | gross_income_lower_threshold_0 | 946.0      |
      | disposable_lower_threshold     | 946.0      |
      | disposable_upper_threshold     | 946.0      |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |    66.0  |
      | total_disposable_income        |   879.0  |

  Scenario: Post MTR - Gross income below lower threshold still needs capital test
    Given I am undertaking a controlled assessment
    And A submission date of "2525-04-10"
    And I add employment income of 400 per month
    And I add a non-disputed main property of value 400000
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | ineligible |
      | gross_income_upper_threshold_0 | 2912.5     |
      | gross_income_lower_threshold_0 | 946.0      |
