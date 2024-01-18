Feature:
  "I submit controlled assessments and see appropriate thresholds"

  Scenario: Gross income is below threshold (and so is disposable income)
    Given I am undertaking a controlled assessment
    And I add other income "friends_or_family" of 2600 per month
    And I add outgoing details for "maintenance_out" of 2500 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |

  Scenario: Gross income is above threshold (but disposable income is under it)
    Given I am undertaking a controlled assessment
    And I add other income "friends_or_family" of 2700 per month
    And I add outgoing details for "maintenance_out" of 2600 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Disposable income is below threshold
    Given I am undertaking a controlled assessment
    And I add other income "friends_or_family" of 1000 per month
    And I add outgoing details for "maintenance_out" of 300 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |

  Scenario: Disposable income is above threshold
    Given I am undertaking a controlled assessment
    And I add other income "friends_or_family" of 1000 per month
    And I add outgoing details for "maintenance_out" of 200 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Capital is below threshold
    Given I am undertaking a controlled assessment
    And I add 7000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |

  Scenario: Capital is above threshold
    Given I am undertaking a controlled assessment
    And I add 9000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Immigration case with capital above threshold
    Given I am undertaking a controlled assessment
    And A first tier immigration case
    And I add 6000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Immigration case with capital below threshold
    Given I am undertaking a controlled assessment
    And A first tier immigration case
    And I add 3000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible |

  Scenario: Asylum case with capital above threshold
    Given I am undertaking a controlled assessment
    And A first tier asylum case
    And I add 8001 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Asylum case with capital below threshold
    Given I am undertaking a controlled assessment
    And A first tier asylum case
    And I add 8000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible |
