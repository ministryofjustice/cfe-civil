module Eligibility
  class GrossIncome
    include ActiveModel::Model
    include ActiveModel::Attributes

    validates :upper_threshold, presence: true

    attribute :upper_threshold, :decimal
    attribute :proceeding_type_code, :string
    attribute :assessment_result, :string

    def lower_threshold
      nil
    end
  end
end
