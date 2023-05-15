class Employment < ApplicationRecord
  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  validates :calculation_method, inclusion: { in: %w[blunt_average most_recent] }, allow_nil: true

  def actively_working?
    !receiving_only_statutory_sick_or_maternity_pay? && employment_payments.any?
  end
end
