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

  def under_18_years_old?(submission_date)
    date_of_birth > (submission_date - 18.years)
  end
end
