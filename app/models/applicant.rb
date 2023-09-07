class Applicant
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date_of_birth, :date
  attribute :employed, :boolean
  attribute :receives_qualifying_benefit, :boolean, default: false
  attribute :receives_asylum_support, :boolean, default: false
  attribute :has_partner_opponent, :boolean, default: false
  attribute :involvement_type, :string, default: "applicant"

  validates :date_of_birth, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }

  def receives_qualifying_benefit?
    receives_qualifying_benefit
  end

  def receives_asylum_support?
    receives_asylum_support
  end
end
