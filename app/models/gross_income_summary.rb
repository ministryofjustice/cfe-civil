class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :cash_transaction_categories, dependent: :destroy
  has_many :cash_transactions, -> { order(date: :asc) }, through: :cash_transaction_categories, dependent: :destroy
end
