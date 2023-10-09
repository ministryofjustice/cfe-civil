class CapitalSummary < ApplicationRecord
  belongs_to :assessment
  has_many :disputed_capital_items, -> { disputed }, class_name: "CapitalItem"
  has_many :disputed_vehicles, -> { disputed }, class_name: "Vehicle"
end
