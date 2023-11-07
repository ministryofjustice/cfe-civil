Feature:
    "Asylum Support"

    Scenario: Asylum supported users receive eligible result without further details needed
      Given I am undertaking upper tribunal certificated asylum assessment
      And A submission date of "2023-04-10"
      And I add the following applicant details for the current assessment:
          | receives_asylum_support     | true       |
      When I retrieve the final assessment
      Then I should see the following overall summary:
          | attribute                    | value    |
          | assessment_result            | eligible |
