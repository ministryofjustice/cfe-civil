Feature:
  "Child care entitlement via outgoings(employed)"

  Scenario: The client is employed, child care submitted as outgoings, gross income > 0
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | benefits_in_kind | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 500.00   |   0  |  0                  | 0                | false                                          |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    And I add the following outgoing details for "child_care" in the current assessment:
      | payment_date | client_id | amount |
      | 2020-02-29   | og-id1    | 200.00 |
      | 2020-03-27   | og-id2    | 200.00 |
      | 2020-04-26   | og-id3    | 200.00 |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 200.0  |

  Scenario: The client is employed, child care submitted as outgoings, gross income = 0
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | benefits_in_kind | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 0        |   0  |  0                  | 0                | false                                          |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    And I add the following outgoing details for "child_care" in the current assessment:
      | payment_date | client_id | amount |
      | 2020-02-29   | og-id1    | 200.00 |
      | 2020-03-27   | og-id2    | 200.00 |
      | 2020-04-26   | og-id3    | 200.00 |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 0.0    |

