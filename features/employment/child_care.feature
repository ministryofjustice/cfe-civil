Feature:
  "Child care entitlement"

  Scenario: The client is receiving statutory sick pay only
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
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

  Scenario: The client is employed
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I create an assessment with the following details:
      | client_reference_id | NP-FULL-1  |
      | submission_date     | 2023-01-10 |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    And I add the following regular_transaction details:
      | category    | frequency | operation | amount |
      | child_care  | monthly   | debit     | 200.0  |
    And I add the following employment details:
      | client_id |     date     |  gross | benefits_in_kind  | tax    | national_insurance  |
      |     C     |  2022-06-22  | 500.00 |      100          | -55.00 |       -25.0         |
      |     C     |  2022-07-22  | 500.00 |      100          | -55.00 |       -25.0         |
      |     C     |  2022-08-22  | 500.00 |      100          | -55.00 |       -25.0         |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 200.0  |

  Scenario: The client is employed, child care submitted as outgoings
    Given I am undertaking a certificated assessment
    And I am using version 6 of the API
    And I create an assessment with the following details:
      | client_reference_id | NP-FULL-1  |
      | submission_date     | 2023-01-10 |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   |
      | 2018-12-20    | FALSE                  | child_relative |
    And I add the following outgoing details for "child_care" in the current assessment:
      | payment_date | client_id | amount |
      | 2020-02-29   | og-id1    | 200.00 |
      | 2020-03-27   | og-id2    | 200.00 |
      | 2020-04-26   | og-id3    | 200.00 |
    And I add the following employment details:
      | client_id |     date     |  gross | benefits_in_kind  | tax    | national_insurance  |
      |     C     |  2022-06-22  | 500.00 |      100          | -55.00 |       -25.0         |
      |     C     |  2022-07-22  | 500.00 |      100          | -55.00 |       -25.0         |
      |     C     |  2022-08-22  | 500.00 |      100          | -55.00 |       -25.0         |
    When I retrieve the final assessment
    Then I should see the following "disposable income" details:
      | attribute                | value  |
      | childcare_allowance      | 200.0  |
