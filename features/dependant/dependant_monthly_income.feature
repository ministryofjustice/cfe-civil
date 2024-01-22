Feature:
  "Dependents with monthly income"

  Scenario: Dependant has non-zero monthly income below the allowance threshold
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2 with monthly income of 100
    And I have a dependant aged 17 with monthly income of 100
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 207.64  |
      | dependant allowance over 16       | 207.64  |

  Scenario: Dependant has non-zero monthly income that exceeds allowance threshold
    Given I am undertaking a certificated assessment
    And I have a dependant aged 2 with monthly income of 400
    And I have a dependant aged 17 with monthly income of 400
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                         | value   |
      | dependant allowance under 16      | 0.0     |
      | dependant allowance over 16       | 0.0     |
