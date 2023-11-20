class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :irregular_income_payments, dependent: :destroy
  has_many :cash_transaction_categories, dependent: :destroy
  has_many :cash_transactions, -> { order(date: :asc) }, through: :cash_transaction_categories, dependent: :destroy
  has_many :student_loan_payments, -> { student_loan }, class_name: "IrregularIncomePayment"
  has_many :unspecified_source_payments, -> { unspecified_source }, class_name: "IrregularIncomePayment"
end
