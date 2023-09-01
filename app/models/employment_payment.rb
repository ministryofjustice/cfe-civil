EmploymentPayment = Data.define(:date, :gross_income, :benefits_in_kind, :tax, :national_insurance, :client_id) do
  def initialize(date:, gross_income:, benefits_in_kind:, tax:, national_insurance:, client_id:)
    super(date: (date.is_a?(String) ? Date.parse(date) : date), gross_income: gross_income.to_d, benefits_in_kind: benefits_in_kind.to_d, tax: tax.to_d, national_insurance: national_insurance.to_d, client_id:)
  end

  def tax=(tax)
    tax
  end

  def national_insurance=(national_insurance)
    national_insurance
  end
end
