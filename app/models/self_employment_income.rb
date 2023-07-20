class SelfEmploymentIncome < EmploymentOrSelfEmploymentIncome
  def benefits_in_kind
    0.0
  end

  def entitles_employment_allowance?
    false
  end
end
