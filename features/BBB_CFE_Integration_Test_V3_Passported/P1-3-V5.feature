Feature:
  ""Certificated domestic abuse assessment which is passported.
  Capital includes bank accounts, non-liquid capital and a main home
  (that is nil due to 3% sale costs and disregard). Assessed capital
  below the lower threshold so the result is eligible.""

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And A submission date of "2019-05-29"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I add 1100 capital of type "bank_accounts"
    And I add 1000 capital of type "non_liquid_capital"
    And I add a non-disputed main property of value 120000 and mortgage 16400
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value    |
      | assessment_result       | eligible |
      | capital_lower_threshold |   3000.0 |
    Then I should see the following "capital summary" details:
      | attribute                | value    |
      | total_mortgage_allowance | 100000.0 |
      | total_non_liquid         |   1000.0 |
      | total_liquid             |   1100.0 |
      | assessed_capital         |   2100.0 |
