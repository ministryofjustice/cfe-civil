class Employment < ApplicationRecord
  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  def actively_working?
    !receiving_only_statutory_sick_or_maternity_pay? && has_positive_gross_income?
  end

private

  def has_positive_gross_income?
    employment_payments.sum(&:gross_income).positive?
  end
end
