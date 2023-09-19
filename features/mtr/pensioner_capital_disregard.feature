Feature:
  "Pensioner disregard"

  Scenario: Pensioner disregard age is fixed (60 years) and Applicant is 61 years old
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And A submission date of "2020-04-10"
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1959-04-10 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | pensioner_capital_disregard | 100000.0 |

  Scenario: Pensioner disregard age is fixed (60 years) and Applicant is 59 years old
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And A submission date of "2020-04-10"
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1961-04-10 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | pensioner_capital_disregard | 0.0 |

