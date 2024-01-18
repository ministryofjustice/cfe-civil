Feature:
  "Subject Matter Of Dispute Disregard Cap"

  Scenario: SMOD Disregard Cap is applied
    Given I am undertaking a certificated assessment
    And I add disputed main property of value 200000
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                  | value    |
      | subject_matter_of_dispute_disregard | 100000.0 |

  Scenario: SMOD Disregard Cap is removed under MTR rules
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add disputed main property of value 200000
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                  | value    |
      | subject_matter_of_dispute_disregard | 194000.0 |

  Scenario: SMOD Disregard Cap is applied
    Given I am undertaking a controlled assessment
    And I add disputed main property of value 200000
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                  | value    |
      | subject_matter_of_dispute_disregard | 100000.0 |

  Scenario: SMOD Disregard Cap is removed under MTR rules, gross income above lower threshold
    Given I am undertaking a controlled assessment
    And A submission date post-mtr
    And I add employment income of 1000 per month
    And I add disputed main property of value 200000
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                           |  value   |
      | subject_matter_of_dispute_disregard | 200000.0 |

