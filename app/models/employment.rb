class Employment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :client_id, :string
  attribute :type, :string, default: "ApplicantEmployment"
  attribute :receiving_only_statutory_sick_or_maternity_pay, :boolean, default: false
  attribute :submission_date, :date
  attribute :employment_payments

  def entitles_employment_allowance?
    !receiving_only_statutory_sick_or_maternity_pay? && employment_payments.any?
  end

  def receiving_only_statutory_sick_or_maternity_pay?
    !!receiving_only_statutory_sick_or_maternity_pay
  end

  def entitles_childcare_allowance?
    entitles_employment_allowance? && employment_payments.sum(&:gross_income).positive?
  end
end
