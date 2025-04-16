Feature:
  " 1. Eligible
    2. Income contribution
    3. Employed - Multiple employment "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-05"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | DA004     | A                       |
    And I have a dependant aged 3
    And I add the following employment details:
      | client_id |     date     |  gross   | benefits_in_kind |   tax    | national_insurance  |
      |     C     |  2021-12-17  |   272.04 |      0           |    80.20 |          0.0        |
      |     C     |  2021-11-19  |   304.73 |      0           |   115.81 |          0.0        |
      |     C     |  2021-10-22  |   429.41 |      0           |   215.21 |          0.0        |
      |     C     |  2021-09-24  |   935.56 |      0           |   416.18 |        23.95        |
    And I add the following employment details:
      | client_id |     date     |  gross   | benefits_in_kind |   tax    | national_insurance  |
      |     C     |  2021-11-17  |   142.56 |      0           |    28.40 |          0.0        |
      |     C     |  2021-11-10  |   142.56 |      0           |    28.40 |          0.0        |
      |     C     |  2021-11-03  |   142.56 |      0           |    28.40 |          0.0        |
      |     C     |  2021-10-27  |    89.10 |      0           |    17.80 |          0.0        |
      |     C     |  2021-11-20  |      0.0 |      0           |      0.0 |          0.0        |
      |     C     |  2021-11-13  |      0.0 |      0           |      0.0 |          0.0        |
      |     C     |  2021-10-06  |   142.56 |      0           |    28.40 |          0.0        |
      |     C     |  2021-09-29  |      0.0 |      0           |      0.0 |          0.0        |
    And I add other income "friends_or_family" of 300 per month
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 10000 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |
    Then I should see the following "gross income" details:
      | attribute               | value |
      | total_gross_income      | 300.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |  10000.0 |
      | total_capital               |  10000.0 |
      | assessed_capital            |  10000.0 |
      | capital_contribution        |   7000.0 |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |   value |
      | gross_housing_costs            |     5.0 |
      | total_outgoings_and_allowances |  348.08 |
      | total_disposable_income        |  -48.08 |
    And I should see the following remarks indicating caseworker referral
      | type                            |  issue                |
      | client_employment               | multiple_employments  |


