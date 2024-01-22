Feature:
  "I have multiple disputed assets"

  Scenario: A pensioner with disputed savings, property and vehicle
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And I add employment income of 290 per month
    And I add 91000 disputed capital of type "bank_accounts"
    And I add 12000 disputed capital of type "non_liquid_capital"
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                           | value    |
      | total_property                      |      0.0 |
      | subject_matter_of_dispute_disregard | 100000.0 |
      | disputed_non_property_disregard     | 100000.0 |
      | pensioner_capital_disregard         |  10000.0 |
      | pensioner_disregard_applied         |   3000.0 |
      | assessed_capital                    |      0.0 |
