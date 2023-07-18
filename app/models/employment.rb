class Employment < ApplicationRecord
  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  def entitles_employment_allowance?
    !receiving_only_statutory_sick_or_maternity_pay? && employment_payments.any?
  end

  def has_positive_gross_income?
    employment_payments.sum(&:gross_income).positive?
  end
end
