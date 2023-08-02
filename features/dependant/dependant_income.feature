Feature:
  "Dependents with income"

  Scenario: The dependant has monthly income = 0
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 0              |
      | 2013-06-11    | FALSE                  | child_relative | 0              |
      | 2004-06-11    | FALSE                  | child_relative | 0              |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 307.64  |
      | dependant_allowance               | 922.92  |

  Scenario: The dependant has income with amount and frequency (amount = 0 and frequency = monthly)
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 0.0            | monthly          |
      | 2013-06-11    | FALSE                  | child_relative | 0.0            | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 0.0             | monthly          |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 307.64  |
      | dependant_allowance               | 922.92  |

  Scenario: The dependant has monthly income > 0 and < 338
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 100            |
      | 2013-06-11    | FALSE                  | child_relative | 100            |
      | 2004-06-11    | FALSE                  | child_relative | 100            |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 207.64  |
      | dependant_allowance               | 822.92  |


  Scenario: The dependant has income with amount and frequency (amount > 0 and < 338 and frequency = monthly)
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 100           | monthly          |
      | 2013-06-11    | FALSE                  | child_relative | 100           | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 100           | monthly          |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 207.64  |
      | dependant_allowance               | 822.92  |

  Scenario: The dependant has monthly income = 338
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 338            |
      | 2013-06-11    | FALSE                  | child_relative | 338            |
      | 2004-06-11    | FALSE                  | child_relative | 338            |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 0  |
      | dependant_allowance               | 615.28  |

  Scenario: The dependant has income with amount and frequency (amount = 338 and frequency = monthly)
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 338           | monthly          |
      | 2013-06-11    | FALSE                  | child_relative | 338           | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 338           | monthly          |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 0  |
      | dependant_allowance               | 615.28  |

  Scenario: The dependant has monthly income >= 338
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income |
      | 2015-02-11    | FALSE                  | child_relative | 400            |
      | 2013-06-11    | FALSE                  | child_relative | 400            |
      | 2004-06-11    | FALSE                  | child_relative | 400            |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 0  |
      | dependant_allowance               | 615.28  |

  Scenario: The dependant has income with amount and frequency (amount >= 338 and frequency = monthly)
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | income_amount | income_frequency |
      | 2015-02-11    | FALSE                  | child_relative | 400           | monthly          |
      | 2013-06-11    | FALSE                  | child_relative | 400           | monthly          |
      | 2004-06-11    | FALSE                  | child_relative | 400           | monthly          |
    When I retrieve the final assessment
    Then I should see the following "dependant allowance" details:
      | attribute                         | value   |
      | dependant_allowance_under_16      | 615.28  |
      | dependant_allowance_over_16       | 0  |
      | dependant_allowance               | 615.28  |

#  Scenario: The dependant has income with amount and frequency
#    Given I am undertaking a certificated assessment
#    And I am using version 6 of the API
#    And I add the following dependent details for the current assessment:
#      | date_of_birth | in_full_time_education | relationship   | income                            |
#      | 2015-02-11    | FALSE                  | child_relative | {amount: 0, frequency: "monthly"} |
#      | 2013-06-11    | FALSE                  | child_relative | {amount: 0, frequency: "monthly"} |
#      | 2004-06-11    | FALSE                  | child_relative | {amount: 0, frequency: "monthly"} |
#    When I retrieve the final assessment
#    Then I should see the following "dependant allowance" details:
#      | attribute                         | value   |
#      | dependant_allowance_under_16      | 615.28  |
#      | dependant_allowance_over_16       | 307.64  |
#      | dependant_allowance               | 922.92  |
