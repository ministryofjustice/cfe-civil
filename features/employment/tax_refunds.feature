Feature:
  "Tax Refunds"
#  If there is a tax (or NI) refund on any given pay period supplied by HMRC to the Apply service
#  CFE cannot complete the calculation in (1) because there are too many variables as to why a refund was paid.
#  Therefore CFE simply should do a 'blunt average' and treat any tax/NI refunds as zero to achieve this.
#  Then Apply refers the 'calculation problem' to an LAA caseworker to decide what to do

  Scenario: The client is employed, but received a tax refund during the calculation period
    Given I am undertaking a certificated assessment
    And A submission date of "2023-01-10"
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
      | client_employment_tax             | refunds          |
      | client_employment_nic             | refunds          |
      | client_employment_gross_income    | amount_variation |

#  When there are multiple employments, HMRC does not provide unique identifiers tying each pay period to a specific employment
#  Therefore once again the calculation in (1) cannot be achieved but for a different reason/s.
#  So once again - CFE gives up and refers to caseworker.
#
#  Note - Apply has to know how to handle tax/NI refunds and multiple employments with no unique pay period identifier as a
#  consequence of the way HMRC data is returned.
#
  Scenario: The client is employed, but has more than one job
    Given I am undertaking a certificated assessment
    And A submission date of "2023-01-10"
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
      | client_employment   |   multiple_employments  |
