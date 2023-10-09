class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :state_benefits, dependent: :destroy
  has_many :other_income_sources, dependent: :destroy
  has_many :regular_transactions, dependent: :destroy
  has_many :irregular_income_payments, dependent: :destroy
  has_many :cash_transaction_categories, dependent: :destroy

  has_many :student_loan_payments, -> { student_loan }, class_name: "IrregularIncomePayment"
  has_many :unspecified_source_payments, -> { unspecified_source }, class_name: "IrregularIncomePayment"

  def housing_benefit_payments
    state_benefits.find_by(state_benefit_type_id: StateBenefitType.housing_benefit&.id)&.state_benefit_payments || []
  end

  def cash_transactions(operation, category)
    cash_transaction_categories.where(operation:, name: category).flat_map(&:cash_transactions)
  end
end
