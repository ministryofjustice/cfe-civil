module Eligibility
  class DisposableIncome
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :lower_threshold, :decimal
    attribute :upper_threshold, :decimal
    attribute :proceeding_type_code, :string
    attribute :assessment_result, :string
  end
end
