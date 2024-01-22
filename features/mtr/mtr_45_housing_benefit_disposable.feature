Feature:
  "Housing Benefit included in Disposable Income after MTR"

  Scenario: pre-MTR - Housing benefit treated specially
    Given I am undertaking a certificated assessment
    And I add other income "friends_or_family" of 100 per month
    And I add "rent_or_mortgage" outgoings of 50 per month
    And I add housing benefit of 10 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible   |
      | gross housing costs          | 50.0       |
      | net housing costs            | 40.0       |
      # Landlord gets £50 - from £40 from the client and £10 from Housing Benefit
      # i.e. the £10 Housing Benefit is not part of the allowed housing costs (='net housing costs' here)
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 100.0                 |
    And I should see the following "disposable_income_summary" details:
      | attribute                        |  value   |
      | combined_total_disposable_income |  60.0    |
      # £40 'net housing costs' were deducted from £100 income
      # i.e. the £10 Housing Benefit is *not* part of the Disposable Income calculation

  Scenario: Post MTR - Housing benefit included in allowed housing costs / Disposable Income
    Given I am undertaking a certificated assessment
    And A submission date post-mtr
    And I add other income "friends_or_family" of 100 per month
    And I add "rent_or_mortgage" outgoings of 50 per month
    And I add housing benefit of 10 per month
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                    | value      |
      | assessment_result            | eligible   |
      | gross housing costs          | 50.0       |
      | net housing costs            | 50.0       |
      # Landlord gets £50 - from £40 from the client and £10 from Housing Benefit
      # i.e. the £10 Housing Benefit *is* part of the allowed housing costs (='net housing costs' here)
    And I should see the following "gross income" details:
      | attribute                      | value                 |
      | combined_total_gross_income    | 110.0                 |
    And I should see the following "disposable_income_summary" details:
      | attribute                        | value    |
      | combined_total_disposable_income |  60.0    |
      # £50 'allowed housing costs' were deducted from £110 income
      # i.e. the £10 Housing Benefit *is* part of the Disposable Income calculation
