Feature:
  ""PASSPORTED & CAPITAL CONTRIBUTION

  1) Capital test = Failed
  2) Overall Result = Failed
  3) Applicant in Non-Mol so all thresholds are waived.""

  Scenario: Test that the correct output is produced for the following set of data.
  Given I am undertaking a certificated assessment
  And An applicant who receives passporting benefits
  And A submission date of "2019-05-29"
  And I add the following proceeding types in the current assessment:
    | ccms_code | client_involvement_type |
    | DA005     | A                       |
  And I add the following vehicle details for the current assessment:
    | value                     | 1000       |
    | loan_amount_outstanding   | 500        |
    | date_of_purchase          | 2019-02-12 |
    | in_regular_use            | false      |
    | subject_matter_of_dispute | false      |
  And I add a non-disputed main property of value 180000 and mortgage 70000
  And I add the following additional property details for the current assessment:
    | value                     | 60000  |
    | outstanding_mortgage      | 40000  |
    | percentage_owned          | 100    |
    | shared_with_housing_assoc | false  |
    | subject_matter_of_dispute | false  |
  When I retrieve the final assessment
  Then I should see the following overall summary:
    | attribute                         | value                 |
    | assessment_result                 | contribution_required |
    | capital_lower_threshold           | 3000.0                |
  Then I should see the following "capital summary" details:
    | attribute                           | value    |
    | total_liquid                        | 0.0      |
    | total_non_liquid                    | 0.0      |
    | total_vehicle                       | 1000.0   |
    | total_capital                       | 33800.0  |
    | total_mortgage_allowance            | 100000.0 |
    | pensioner_capital_disregard         | 0.0      |
    | assessed_capital                    | 33800.0  |
    | capital_contribution                | 30800.0  |
