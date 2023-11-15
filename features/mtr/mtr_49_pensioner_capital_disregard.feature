Feature:
  "Pensioner disregard"
  # MTR rules: https://github.com/dwp/get-state-pension-date/blob/master/src/spa-data.js

  Scenario: Fixed Pensioner disregard age(60 years)
    Given I am undertaking a certificated assessment
    And A submission date of "2020-04-10"
    And An Applicant of 59 years old
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                   |   value    |
      | pensioner_capital_disregard |    0.0     |

  Scenario: Fixed Pensioner disregard age(60 years)
    Given I am undertaking a certificated assessment
    And A submission date of "2020-04-10"
    And An Applicant of 61 years old
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                   |   value    |
      | pensioner_capital_disregard |  100000.0  |

  Scenario: MTR: DOB based Pensioner disregard age
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And An Applicant of 61 years old
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                   |    value   |
      | pensioner_capital_disregard |     0.0    |

  Scenario: MTR: DOB based Pensioner disregard age
    Given I am undertaking a certificated assessment
    And A submission date of "2525-04-10"
    And An Applicant of 69 years old
    When I retrieve the final assessment
    And I should see the following "capital summary" details:
      | attribute                   |   value    |
      | pensioner_capital_disregard |  100000.0  |
