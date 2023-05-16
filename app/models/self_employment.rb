class SelfEmployment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :receiving_only_statutory_sick_or_maternity_pay, :boolean

  attribute :tax, :decimal
  attribute :national_insurance, :decimal
  attribute :gross, :decimal
  attribute :frequency, :string

  validates :tax, :national_insurance, :gross, :frequency, presence: true
end
