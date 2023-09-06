EmploymentPayment = Data.define(:date, :gross_income, :benefits_in_kind, :tax, :national_insurance, :client_id) do
  def initialize(date:, client_id:, gross_income: 0.0, benefits_in_kind: 0.0, tax: 0.0, national_insurance: 0.0)
    super(date: date, gross_income: gross_income.to_d, benefits_in_kind: benefits_in_kind.to_d, tax: tax.to_d, national_insurance: national_insurance.to_d, client_id:)
  end

  def tax=(tax)
    tax
  end

  def national_insurance=(national_insurance)
    national_insurance
  end
end
