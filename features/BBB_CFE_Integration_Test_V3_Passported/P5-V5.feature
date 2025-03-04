Feature:
  "Certificated domestic abuse assessment which is passported.
  Capital includes bank accounts, vehicle and a main home (that is nil due to negative equity).
  Assessed capital below the lower threshold so the result is eligible."

  Scenario: Test that the correct output is produced for the following set of data.
  Given I am undertaking a certificated assessment
  And An applicant who receives passporting benefits
  And A submission date of "2019-05-29"
  And I add the following proceeding types in the current assessment:
    | ccms_code | client_involvement_type |
    | DA005     | A                       |
  And I add 100 capital of type "bank_accounts"
  And I add the following vehicle details for the current assessment:
    | value                     | 1000       |
    | loan_amount_outstanding   | 500        |
    | date_of_purchase          | 2019-02-12 |
    | in_regular_use            | false      |
    | subject_matter_of_dispute | false      |
  And I add a non-disputed main property of value 150000 and mortgage 230000
  When I retrieve the final assessment
  Then I should see the following overall summary:
    | attribute                         | value                 |
    | assessment_result                 | eligible              |
    | capital_lower_threshold           | 3000.0                |
  Then I should see the following "capital summary" details:
    | attribute                           | value    |
    | total_liquid                        | 100.0    |
    | total_non_liquid                    | 0.0      |
    | total_vehicle                       | 1000.0   |
    | total_mortgage_allowance            | 100000.0 |
    | total_capital                       | 1100.0   |
    | pensioner_capital_disregard         | 0.0      |
    | assessed_capital                    | 1100.0   |
    | capital_contribution                | 0.0      |

