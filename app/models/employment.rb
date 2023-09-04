Employment = Data.define(:name, :client_id, :receiving_only_statutory_sick_or_maternity_pay, :employment_payments, :type, :submission_date) do
  def initialize(name:, client_id:, receiving_only_statutory_sick_or_maternity_pay:, employment_payments:, submission_date:, type: "ApplicantEmployment")
    super(name:, client_id:, receiving_only_statutory_sick_or_maternity_pay:, employment_payments:, type:, submission_date:)
  end

  # def submission_date=(submission_date)
  #   submission_date
  # end
  #
  # def submission_date
  #   submission_date
  # end

  def entitles_employment_allowance?
    !receiving_only_statutory_sick_or_maternity_pay? && employment_payments.any?
  end

  def receiving_only_statutory_sick_or_maternity_pay?
    receiving_only_statutory_sick_or_maternity_pay
  end

  def entitles_childcare_allowance?
    entitles_employment_allowance? && employment_payments.sum(&:gross_income).positive?
  end
end
