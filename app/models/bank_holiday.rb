class BankHoliday < ApplicationRecord
  serialize :dates, Array

  scope :by_updated_at, -> { order(updated_at: :asc) }

  validates :dates, presence: true

  def self.dates
    GovukBankHolidayRetriever.dates
  end
end
