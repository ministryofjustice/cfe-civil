Feature:
  "Immigration and Asylum MTR thresholds"

  Scenario: Asylum case before MTR
    Given I am undertaking upper tribunal certificated asylum assessment
    And A submission date of "2023-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 8000.0  |
      | capital_upper_threshold      | 8000.0  |
      | disposable_upper_threshold   | 733.0   |
      | disposable_lower_threshold   | 733.0   |

  Scenario: Asylum case after MTR
    Given I am undertaking upper tribunal certificated asylum assessment
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 7000.0  |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 622.0   |

  Scenario: Immigration case before MTR
    Given I am undertaking upper tribunal certificated immigration assessment
    And A submission date of "2023-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 3000.0  |
      | capital_upper_threshold      | 3000.0  |
      | disposable_upper_threshold   | 733.0   |
      | disposable_lower_threshold   | 733.0   |

  Scenario: Immigration case after MTR
    Given I am undertaking upper tribunal certificated immigration assessment
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 7000.0  |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 622.0   |

  Scenario: Immigration controlled case before MTR
    Given I am undertaking first tier controlled immigration assessment
    And A submission date of "2023-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 3000.0  |
      | capital_upper_threshold      | 3000.0  |
      | disposable_upper_threshold   | 733.0   |
      | disposable_lower_threshold   | 733.0   |

  Scenario: Immigration controlled case after MTR
    Given I am undertaking first tier controlled immigration assessment
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 11000.0 |
      | capital_upper_threshold      | 11000.0 |
      | disposable_upper_threshold   | 946.0   |
      | disposable_lower_threshold   | 946.0   |

  Scenario: Asylum case before MTR
    Given I am undertaking first tier controlled asylum assessment
    And A submission date of "2023-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 8000.0  |
      | capital_upper_threshold      | 8000.0  |
      | disposable_upper_threshold   | 733.0   |
      | disposable_lower_threshold   | 733.0   |

  Scenario: Asylum case after MTR
    Given I am undertaking first tier controlled asylum assessment
    And A submission date of "2525-04-10"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value   |
      | capital_lower_threshold      | 11000.0  |
      | capital_upper_threshold      | 11000.0 |
      | disposable_lower_threshold   | 946.0   |
      | disposable_upper_threshold   | 946.0   |
