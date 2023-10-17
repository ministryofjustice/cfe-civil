StateBenefit = Data.define(:state_benefit_payments, :exclude_from_gross_income, :state_benefit_name) do
  def exclude_from_gross_income?
    exclude_from_gross_income
  end

  def housing_benefit?
    state_benefit_name == "housing_benefit"
  end
end
