Feature:
  "Child care entitlement via regular transactions(employed)"

  Scenario: The client is receiving statutory sick pay only
    Given I am undertaking a certificated assessment
    And I create an assessment with the following details:
      | client_reference_id | NP-FULL-1  |
      | submission_date     | 2023-01-10 |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    And I add the following regular_transaction details:
      | category    | frequency | operation | amount |
      | child_care  | monthly   | debit     | 200.0  |
    And I add the following statutory sick pay details for the client:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
      |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
      |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
      |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                 | value  |
      | childcare_allowance       | 0.0    |

  Scenario: The client is employed, child care submitted as regular_transactions, gross income > 0
    Given I am undertaking a certificated assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | benefits_in_kind | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 500.00   |   0  |  0                  | 0                | false                                          |
    And I add the following regular_transaction details:
      | category    | frequency | operation | amount |
      | child_care  | monthly   | debit     | 200.0  |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 200.0      |

  Scenario: The client is employed, child care submitted as regular_transactions, gross = 0
    Given I am undertaking a certificated assessment
    And I add the following "client" employment details in the current assessment:
      | frequency | gross    |  tax |  national_insurance | benefits_in_kind | receiving_only_statutory_sick_or_maternity_pay |
      | monthly   | 0        |   0  |  0                  | 0                | false                                          |
    And I add the following regular_transaction details:
      | category    | frequency | operation | amount |
      | child_care  | monthly   | debit     | 200.0  |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                      | value      |
      | childcare_allowance            | 0.0        |
