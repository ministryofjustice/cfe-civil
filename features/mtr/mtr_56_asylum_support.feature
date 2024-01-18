Feature:
  "Asylum Support (non-means tested)"

  Scenario: Pre-MTR Asylum Support asylum case - eligible
    Given I am undertaking upper tribunal certificated asylum assessment
    And The applicant is receiving asylum support
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible |

  Scenario: Post-MTR Asylum Support asylum case - still eligible
    Given I am undertaking upper tribunal certificated asylum assessment
    And A submission date post-mtr
    And The applicant is receiving asylum support
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |

  Scenario: pre-MTR asylum support ineligible as non asylum case
    Given I am undertaking a certificated assessment
    And The applicant is receiving asylum support
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | ineligible |

  Scenario: post-MTR asylum support eligible for non asylum case
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And The applicant is receiving asylum support
    And I add employment income of 3000 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value    |
      | assessment_result            | eligible |
