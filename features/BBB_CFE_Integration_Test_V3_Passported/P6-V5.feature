Feature:
  "Certificated domestic abuse assessment which is passported.
  Capital includes bank accounts, vehicle (that is nil due to regular use) and a main home
  (that is nil due to disregard).
  Assessed capital below the lower threshold so the result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
  Given I am undertaking a certificated assessment
  And An applicant who receives passporting benefits
  And A submission date of "2019-05-29"
  And I add the following proceeding types in the current assessment:
    | ccms_code | client_involvement_type |
    | DA005     | A                       |
  And I add 600 capital of type "bank_accounts"
  And I add the following vehicle details for the current assessment:
    | value                     | 8000       |
    | loan_amount_outstanding   | 6000       |
    | date_of_purchase          | 2017-08-22 |
    | in_regular_use            | true       |
    | subject_matter_of_dispute | false      |
  And I add a non-disputed 50 percent share main property of value 200000 and mortgage 60000
  When I retrieve the final assessment
  Then I should see the following overall summary:
    | attribute                         | value                 |
    | assessment_result                 | eligible              |
    | capital_lower_threshold           | 3000.0                |
  Then I should see the following "capital summary" details:
    | attribute                           | value    |
    | total_liquid                        | 600.0    |
    | total_non_liquid                    | 0.0      |
    | total_vehicle                       | 0.0      |
    | total_mortgage_allowance            | 100000.0 |
    | total_capital                       | 600.0    |
    | pensioner_capital_disregard         | 0.0      |
    | assessed_capital                    | 600.0    |
    | capital_contribution                | 0.0      |
