Feature:
  "Income contributions"

  Scenario: Just above the contribution threshold (so zero)
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 1234 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                   | value     |
      | assessment_result           | eligible  |
      | disposable_lower_threshold  |  622.0    |
    And I should see the following "disposable_income_summary" details:
      | attribute                   |  value   |
      | total_disposable_income     |  652.0   |
      | income_contribution         |    0.0   |

  Scenario: A bit more above the contribution threshold
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 1204 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | contribution_required |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  682.0  |
      | income_contribution     |  24.0   |

  Scenario: Band B
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 1126 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | contribution_required |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  760.0  |
      | income_contribution     |  61.2   |

  Scenario: Band C
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 1018 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | contribution_required |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  868.0  |
      | income_contribution     |  132.0  |

  Scenario: Above Band C
    Given I am undertaking a certificated assessment
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 910 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  976.0  |

  Scenario: Above Band C Domestic abuse case - contributions continue at 80%
    Given I am undertaking a certificated assessment
    And A domestic abuse case
    And A submission date of "2525-12-31"
    And I add employment income of 1952 per month
    And I add outgoing details for "rent_or_mortgage" of 910 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | contribution_required |
    And I should see the following "disposable_income_summary" details:
      | attribute               | value   |
      | total_disposable_income |  976.0  |
      | income_contribution     |  218.4  |

