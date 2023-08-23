class CapitalSummary < ApplicationRecord
  belongs_to :assessment

  has_many :properties, dependent: :destroy
  has_many :additional_properties, -> { additional }, inverse_of: :capital_summary, class_name: "Property", dependent: :destroy
  has_one :main_home, -> { main_home }, inverse_of: :capital_summary, class_name: "Property", dependent: :destroy
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
