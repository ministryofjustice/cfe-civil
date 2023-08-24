class CapitalSummary < ApplicationRecord
  belongs_to :assessment
  has_many :eligibilities,
           class_name: "Eligibility::Capital",
           foreign_key: :parent_id,
           inverse_of: :capital_summary,
           dependent: :destroy
  has_many :disputed_capital_items, -> { disputed }, class_name: "CapitalItem"
  has_many :disputed_vehicles, -> { disputed }, class_name: "Vehicle"

  def summarized_assessment_result
    Utilities::ResultSummarizer.call(eligibilities.map(&:assessment_result))
  end
end
