Feature:
  "Gross Income Threshold"

  Scenario: Case after MTR data
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 2912.5  |

