Feature:
  "Immigration and Asylum MTR thresholds"

  Scenario: Asylum case after MTR
    Given I am undertaking a certificated assessment
    And A first tier asylum case
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 7000.0  |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 315.0   |

  Scenario: Immigration case after MTR
    Given I am undertaking a certificated assessment
    And A first tier immigration case
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 7000.0  |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 315.0   |

  Scenario: Immigration controller case after MTR
    Given I am undertaking a controlled assessment
    And A first tier immigration case
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 11000.0 |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 946.0   |

