class Assessment < ApplicationRecord
  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type, presence: true

  has_one :applicant

  has_many :bank_accounts
  has_many :benefit_receipts
  has_many :dependants
  has_many :non_liquid_assets
  has_many :outgoings
  has_many :properties
  has_many :vehicles
  has_many :wage_slips
end
