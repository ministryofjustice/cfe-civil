Feature:
  " 1. Most recent (within £60 tolerance)
    2. Variations - MOST RECENT
    3. 1 weekly "

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2022-01-12"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 3
    And I add the following employment details:
      | client_id |     date     |  gross   | benefits_in_kind |   tax   | national_insurance  |
      |     C     |  2022-01-11  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2022-01-04  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-12-28  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-12-21  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-12-14  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-12-07  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-11-30  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-11-23  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-11-30  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-11-23  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-11-16  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-11-09  |   210.0  |      0           |    0.0  |          0.0        |
      |     C     |  2021-11-02  |   220.0  |      0           |   -5.0  |         -3.0        |
      |     C     |  2021-10-26  |   210.0  |      0           |    0.0  |          0.0        |
#    And I add weekly employment income with the following payments:
#      | period   | income | tax   | ni    |
#      | week 1   |  220.0 |   5.0 | 3.0   |
#      | week 2   |  210.0 |   0.0 | 0.0   |
#      | week 3   |  220.0 |   5.0 | 3.0   |
#      | week 4   |  210.0 |   0.0 | 0.0   |
#      | week 5   |  220.0 |   5.0 | 3.0   |
#      | week 6   |  210.0 |   0.0 | 0.0   |
#      | week 7   |  220.0 |   5.0 | 3.0   |
#      | week 8   |  210.0 |   0.0 | 0.0   |
#      | week 9   |  220.0 |   5.0 | 3.0   |
#      | week 10  |  210.0 |   0.0 | 0.0   |
#      | week 11  |  220.0 |   5.0 | 3.0   |
#      | week 12  |  210.0 |   0.0 | 0.0   |
    And I add outgoing details for "rent_or_mortgage" of 5 per month
    And I add 500 capital of type "bank_accounts"
    When I retrieve the final assessment
#    Then I should see the following overall summary:
#      | attribute                      | value    |
#      | assessment_result              | contribution_required |
    Then I should see the following "capital summary" details:
      | attribute                      |   value  |
      | total_liquid                   |   500.0  |
    Then I should see the following "employment" details:
      | attribute                      | value   |
      | gross_income                   | 953.33  |
      | tax                            | -21.67   |
      | national_insurance             | -13.0    |
      | net_employment_income          | 1029.97  |
      Then I should see the following "gross income" details:
        | attribute                      |  value   |
        | total_gross_income             |  953.33  |
    And I should see the following "disposable_income_summary" details:
      | attribute                      |  value |
      | gross_housing_costs            |   5.0  |
      | dependant_allowance            | 298.08 |
      | total_outgoings_and_allowances | 382.75 |
      | total_disposable_income        | 570.58 |
      | income_contribution            | 101.41 |


