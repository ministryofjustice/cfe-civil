Feature:
  "Certificated domestic abuse assessment which is passported.
  Capital includes bank accounts, non-liquid capital, vehicle and a main home
  (that is nil due to 3% sale costs and disregard). Assessed capital above the
  lower threshold so the result is capital contribution required."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And A submission date of "2019-05-29"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I add 1000 capital of type "bank_accounts"
    And I add 2000 capital of type "non_liquid_capital"
    And I add the following vehicle details for the current assessment:
      | value                     |       5001 |
      | loan_amount_outstanding   |          0 |
      | date_of_purchase          | 2019-01-01 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | false      |
    And I add a non-disputed main property of value 120000 and mortgage 16400
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute               | value                 |
      | assessment_result       | contribution_required |
      | capital_lower_threshold |                3000.0 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_liquid                |   1000.0 |
      | total_non_liquid            |   2000.0 |
      | total_vehicle               |   5001.0 |
      | total_capital               |   8001.0 |
      | total_mortgage_allowance    | 100000.0 |
      | pensioner_capital_disregard |      0.0 |
      | assessed_capital            |   8001.0 |
      | capital_contribution        |   5001.0 |
