class SelfEmploymentIncome < EmploymentIncome
  def benefits_in_kind
    0.0
  end

  def actively_working?
    false
  end
end
