Vehicle = Data.define(:value, :loan_amount_outstanding, :date_of_purchase, :in_regular_use, :subject_matter_of_dispute) do
  def in_regular_use?
    in_regular_use
  end

  def age_in_months(submission_date)
    Calculators::VehicleAgeCalculator.new(date_of_purchase, submission_date).in_months
  end
end
