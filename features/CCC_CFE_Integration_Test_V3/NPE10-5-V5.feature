Feature:
  ""NON-PASSPORT TEST - CONCERN4 - CHILDCARE NOT ALLOWED
  1) Post 6th April dependant Rates
  2) Client has education income and dependant under 15""
  3) CHILDCARE NOT ALLOWED is determined by the applicant not being employed
  or not in full time education (as per NPE10-4-V5.feature)

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And A submission date of "2020-04-21"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I have a dependant aged 2
    And I add other income "friends_or_family" of 100 per month
    And I add outgoing details for "child_care" of 200 per month
    And I add 3002 capital of type "bank_accounts"
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |
      | capital_lower_threshold      | 3000.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | dependant_allowance            |  296.65  |
      | total_outgoings_and_allowances |  296.65  |
      | total_disposable_income        | -196.65  |


