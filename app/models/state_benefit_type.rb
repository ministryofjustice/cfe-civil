class StateBenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :name, presence: true
  validates :category, inclusion: { in: (%w[carer_disability low_income other uncategorised] + [nil]),
                                    message: "Invalid category" }

  def self.as_cfe_json
    all.map(&:as_cfe_json)
  end

  def as_cfe_json
    as_json(only: %i[name label dwp_code exclude_from_gross_income category])
  end
end
