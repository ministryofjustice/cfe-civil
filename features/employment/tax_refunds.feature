Feature:
  "Tax Refunds"

  Scenario: The client is employed, but received a tax refund during the calculation period
    Given I am using version 6 of the API
    And I create an assessment with the following details:
      | client_reference_id | NP-FULL-1  |
      | submission_date     | 2023-01-10 |
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1979-12-20 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE013     | A                       |
    And I add the following employment details:
      | client_id |     date     |  gross  | benefits_in_kind  | tax    | national_insurance  |
      | C         | 2022-06-22   | -200.00 | 0                 |-30.00  |-25.00               |
      | C         | 2022-07-22   |  500.00 | 100               |100.00  | 50.00               |
      | C         | 2022-08-22   | -200.00 | 0                 |-30.00  |-25.00               |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | gross_income               | 33.33  |
      | benefits_in_kind           | 33.33  |
      | fixed_employment_deduction | -45.0  |
      | tax                        | 13.33  |
      | national_insurance         |   0.0  |
      | net_employment_income      | 34.99  |
    And I should see the following remarks indicating caseworker referral
      | type                       |  issue           |
      | employment_tax             | refunds          |
      | employment_nic             | refunds          |
      | employment_gross_income    | amount_variation |

  Scenario: The client is employed, but has more than one job
    Given I am using version 6 of the API
    And I create an assessment with the following details:
      | client_reference_id | NP-FULL-1  |
      | submission_date     | 2023-01-10 |
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1979-12-20 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE013     | A                       |
    And I add the following employment details:
      | client_id |     date     |  gross  | benefits_in_kind  | tax    | national_insurance |
      | C         |  2022-06-22  |  500    |0                  |-55     |-25                 |
      | C         |  2022-07-22  |  500    |0                  |-55     | -25                |
      | C         |  2022-08-22  |  500    |0                  |-55     |-25                 |
    And I add the following employment details:
      | client_id |     date     |  gross  | benefits_in_kind  | tax    | national_insurance |
      | D         |  2022-06-22  |  500    |0                  |-55     |-25                 |
      | D         |  2022-07-22  |  500    |0                  |-55     |-25                 |
      | D         |  2022-08-22  |  500    |0                  |-55     |-25                 |
    When I retrieve the final assessment
    Then I should see the following "employment" details:
      | attribute                  | value  |
      | gross_income               |   0.0  |
      | benefits_in_kind           |   0.0  |
      | fixed_employment_deduction | -45.0  |
      | tax                        |   0.0  |
      | national_insurance         |   0.0  |
      | net_employment_income      | -45.0  |
    And I should see the following remarks indicating caseworker referral
      | type         |          issue          |
      | employment   |   multiple_employments  |
