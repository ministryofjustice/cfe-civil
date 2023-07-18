class EmploymentIncome < EmploymentOrSelfEmploymentIncome
  attribute :receiving_only_statutory_sick_or_maternity_pay, :boolean
  attribute :benefits_in_kind, :decimal

  def entitles_employment_allowance?
    !receiving_only_statutory_sick_or_maternity_pay
  end
end
