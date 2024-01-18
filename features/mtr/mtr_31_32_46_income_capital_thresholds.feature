Feature:
  "New Thresholds for Gross, Disposable and Capital"

  Scenario: Above gross threshold after MTR
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2950 per month
    And I add outgoing details for "rent_or_mortgage" of 2200 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | ineligible |
      | gross_income_upper_threshold_0 | 2912.5     |

  Scenario: Below gross threshold after MTR
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 2200 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | gross_income_upper_threshold_0 | 2912.5   |
      | disposable_lower_threshold     | 622.0    |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_disposable_income        |   634.0  |

  Scenario: Below lower disposable threshold after MTR
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 2600 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | disposable_lower_threshold     | 622.0    |
      | disposable_upper_threshold     | 946.0    |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_disposable_income        |   234.0  |

  Scenario: Between disposable thresholds post MTR
#  band zero extends up to £622, plus £20 minimum makes lower threshold look high
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 2160 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | contribution_required |
      | gross_income_upper_threshold_0 |       2912.5          |
      | disposable_lower_threshold     |        622.0          |
      | disposable_upper_threshold     |        946.0          |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |  2226.0  |
      | total_disposable_income        |   674.0  |
      | income_contribution            |    20.8  |

  Scenario: Above disposable thresholds post MTR
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 1860 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
      | assessment_result              | ineligible |
      | disposable_upper_threshold     | 946.0      |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |  1926.0  |
      | total_disposable_income        |   974.0  |

  Scenario: Below lower disposable threshold after MTR, above capital lower threshold
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 2600 per month
    And I add the following main property details for the current assessment:
      | value                      | 400000 |
      | outstanding_mortgage       | 130000 |
      | percentage_owned           |    100 |
      | shared_with_housing_assoc  | false  |
      | subject_matter_of_dispute  | false  |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value                 |
#      | assessment_result              | contribution_required |
      | disposable_lower_threshold     | 622.0                 |
      | disposable_upper_threshold     | 946.0                 |
      | capital_lower_threshold        | 7000.0                |
      | capital_upper_threshold        | 11000.0               |
    And I should see the following "capital summary" details:
      | attribute                      | value    |
      | total_capital                  |  73000.0 |
      | assessed_capital               |   8000.0 |
      | capital_contribution           |   1000.0 |

  Scenario: Below lower disposable threshold after MTR, above capital upper threshold
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add employment income of 2900 per month
    And I add outgoing details for "rent_or_mortgage" of 2600 per month
    And I add the following main property details for the current assessment:
      | value                      | 400000 |
      | outstanding_mortgage       | 126000 |
      | percentage_owned           |    100 |
      | shared_with_housing_assoc  | false  |
      | subject_matter_of_dispute  | false  |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                      | value      |
      | assessment_result              | ineligible |
      | capital_lower_threshold        | 7000.0     |
      | capital_upper_threshold        | 11000.0    |
    And I should see the following "capital summary" details:
      | attribute                      | value    |
      | total_capital                  |  77000.0 |
      | assessed_capital               |  12000.0 |

