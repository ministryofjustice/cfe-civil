Feature:
  "I have a property"

  Scenario: A property where the main home equity is smaller than the capped disregard figure
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 50 percent share main property of value 150000 and mortgage 100000
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 150000.0 |
      | transaction_allowance      |   4500.0 |
      | net_value                  |  45500.0 |
      | net_equity                 |  22750.0 |
      | main_home_equity_disregard |  22750.0 |
      | assessed_equity            |      0.0 |
      | subject_matter_of_dispute  |   false  |
    And I should see the following "capital summary" details:
      | attribute                  | value    |
      | total_property             |      0.0 |
      | assessed_capital           |      0.0 |

  Scenario: A property with ownership shared with another individual
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 25 percent share main property of value 530000 and mortgage 90646
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 530000.0 |
      | transaction_allowance      |  15900.0 |
      | net_value                  | 423454.0 |
      | net_equity                 | 105863.5 |
      | main_home_equity_disregard | 100000.0 |
      | assessed_equity            |   5863.5 |

  Scenario: A property with ownership shared with a housing association
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 25 percent share with a housing association on a main property of value 530000 and mortgage 90646
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 530000.0 |
      | transaction_allowance      |  15900.0 |
      | net_value                  | 423454.0 |
      | net_equity                 |  25954.0 |
      | main_home_equity_disregard |  25954.0 |
      | assessed_equity            |      0.0 |

#  This test uses a float value 12.5 as the percentage owned and the results seem to blow up providing negative figures
#  Scenario: A property with ownership shared with a housing association
#    Given I am undertaking a certificated assessment
#    And An applicant who receives passporting benefits
#    And I add a non-disputed 12.5 percent share with a housing association on a main property of value 530000 and mortgage 90646
#    When I retrieve the final assessment
#    Then I should see the following "main property" details:
#      | attribute                  | value    |
#      | value                      | 530000.0 |
#      | transaction_allowance      |  15900.0 |
#      | net_value                  | 423454.0 |
#      | net_equity                 | -40296.0 |
#      | main_home_equity_disregard | -40296.0 |
#      | assessed_equity            |      0.0 |

  Scenario: A property with ownership shared with a housing association
    Given I am undertaking a controlled assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 25 percent share main property of value 530000 and mortgage 90646
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 530000.0 |
      | net_value                  | 439354.0 |
      | net_equity                 | 109838.5 |
      | main_home_equity_disregard | 100000.0 |
      | assessed_equity            |   9838.5 |

  Scenario: A property with ownership shared with a housing association
    Given I am undertaking a controlled assessment
    And An applicant who receives passporting benefits
    And I add a non-disputed 25 percent share with a housing association on a main property of value 530000 and mortgage 90646
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 530000.0 |
      | net_value                  | 439354.0 |
      | net_equity                 |  41854.0 |
      | main_home_equity_disregard |  41854.0 |
      | assessed_equity            |      0.0 |

