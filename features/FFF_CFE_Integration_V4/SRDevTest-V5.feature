Feature:
    "Certificated assessment for an applicant in domestic abuse and child order proceedings.
    The client is over 60 and has 3 child dependants and 2 adult dependants.
    Income from friends or family and child benefit and outgoings for rent and childcare.
    Capital includes bank accounts, non-liquid capital, main home and vehicle.
    The capital is over the upper threshold therefore the overall result is,
    partially eligible and capital contributions are required for the DA proceedings."

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am undertaking a certificated assessment
    And An applicant who is a pensioner
    And A submission date of "2019-05-29"
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
      | SE013     | A                       |
    And I have a dependant aged 14
    And I have a dependant aged 11
    And I have a dependant aged 9
    And I have a dependant aged 30
    And I have a dependant aged 32
    And I add "friends_or_family" of multiple regular_transactions, of 1415, "monthly" of "credit"
    And I add "benefits" of multiple regular_transactions, of 200, "four_weekly" of "credit"
    And I add "rent_or_mortgage" of multiple regular_transactions, of 50, "monthly" of "debit"
    And I add "child_care" of multiple regular_transactions, of 100, "monthly" of "debit"
    And I add 300 capital of type "bank_accounts"
    And I add 500 capital of type "non_liquid_capital"
    And I add a non-disputed 50 percent share main property of value 500000 and mortgage 150000
    And I add the following vehicle details for the current assessment:
      | value                     |     9000.0 |
      | loan_amount_outstanding   |        0.0 |
      | date_of_purchase          | 2018-05-20 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | false      |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute         | value              |
      | assessment_result | partially_eligible |
    Then I should see the following "gross income" details:
      | attribute          | value   |
      | total_gross_income | 1631.67 |
    Then I should see the following "capital summary" details:
      | attribute                   | value    |
      | total_capital               | 102300.0 |
      | total_liquid                |    300.0 |
      | total_non_liquid            |    500.0 |
      | total_vehicle               |   9000.0 |
      | total_mortgage_allowance    | 100000.0 |
      | pensioner_capital_disregard |  60000.0 |
      | assessed_capital            |  42300.0 |
      | capital_contribution        |  39300.0 |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value   |
      | dependant_allowance            | 1457.45 |
      | total_outgoings_and_allowances | 1507.45 |
      | total_disposable_income        |  124.22 |
