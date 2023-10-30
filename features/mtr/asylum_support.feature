Feature:
  "Asylum Support (non-means tested)"

  Scenario: Asylum Support eligibility before MTR
    Given I am undertaking upper tribunal certificated asylum assessment
    And A submission date of "2023-04-10"
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1979-12-20 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
      | receives_asylum_support     | true       |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | A                       |
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: Asylum Support eligibility after MTR
    Given I am undertaking upper tribunal certificated asylum assessment
    And A submission date of "2525-04-10"
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1979-12-20 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
      | receives_asylum_support     | true       |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | SE014     | A                       |
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
