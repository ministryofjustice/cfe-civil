class DisposableIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :outgoings, dependent: :destroy, class_name: "Outgoings::BaseOutgoing"
  has_many :childcare_outgoings, dependent: :destroy, class_name: "Outgoings::Childcare"
  has_many :housing_cost_outgoings, dependent: :destroy, class_name: "Outgoings::HousingCost"
  has_many :maintenance_outgoings, dependent: :destroy, class_name: "Outgoings::Maintenance"
  has_many :legal_aid_outgoings, dependent: :destroy, class_name: "Outgoings::LegalAid"
  has_many :pension_contribution_outgoings, dependent: :destroy, class_name: "Outgoings::PensionContribution"
end
