Feature:
  "Self Employment"

  Scenario: 1 The single client is employed, has 1 job and is not receiving SSP/SMP
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind | tax | national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                | -50 | -30                | false                                          |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 2 The single client is employed, has 1 job and is receiving SSP/SMP
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind | tax  | national_insurance  | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 3 The single client is employed, has 2 jobs and is receiving SSP/SMP for one of them
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind | tax  |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 4 The single client is unemployed
    Given I am undertaking a controlled assessment
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 5 The single client is self-employed
    Given I am undertaking a controlled assessment
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 6 The single client is employed & self-employed
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    | tax |  national_insurance |
      | monthly   | 1200.00  | -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 7 The single client is employed (receiving SSP/SMP) & self-employed
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
    And I add the following "client" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 8 The partner is employed, has 1 job and not receiving SSP/SMP
    Given I am undertaking a controlled assessment
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    When I retrieve the final assessment
    Then I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 9 The partner is employed, has 1 job and is receiving SSP/SMP
    Given I am undertaking a controlled assessment
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax | national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                | true                                           |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 10: The partner is employed, has 2 jobs and is receiving SSP/SMP for one of them
    Given I am undertaking a controlled assessment
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    When I retrieve the final assessment
    Then I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 11: Both are unemployed
    Given I am undertaking a controlled assessment
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 70000.00 |
      | outstanding_mortgage        | 69000.00 |
      | percentage_owned            | 100      |
      | shared_with_housing_assoc   | false    |
      | subject_matter_of_dispute   | false    |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |
    And I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 12: The partner is self-employed
    Given I am undertaking a controlled assessment
    And I add the following "partner" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |
    And I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 13: The partner is employed & self-employed
    Given I am undertaking a controlled assessment
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    And I add the following "partner" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |
    And I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 14: The partner is employed (receiving SSP/SMP) & self-employed
    Given I am undertaking a controlled assessment
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | true                                           |
    And I add the following "partner" self employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance |
      | monthly   | 1200.00  |  -50 | -30                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |
    And I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | 0.0      |

  Scenario: 15 - The client and partner are both employed
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind | tax  |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |
    And I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |

  Scenario: 16 - The client is employed, has 2 jobs and the partner is also employed
    Given I am undertaking a controlled assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    And I add the following "partner" employment details in the current assessment:
      | frequency | gross    | benefits_in_kind |  tax |  national_insurance | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 1200.00  | 0                |  -50 | -30                 | false                                          |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |
    Then I should see the following "partner_employment" details:
      | attribute                  | value    |
      | fixed_employment_deduction | -45.0    |
