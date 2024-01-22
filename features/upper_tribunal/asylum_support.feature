Feature:
    "Asylum Support"

    Scenario: Asylum supported users receive eligible result without further details needed
      Given I am undertaking upper tribunal certificated asylum assessment
      And The applicant is receiving asylum support
      When I retrieve the final assessment
      Then I should see the following overall summary:
          | attribute                    | value    |
          | assessment_result            | eligible |
