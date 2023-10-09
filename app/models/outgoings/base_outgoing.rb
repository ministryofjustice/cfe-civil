module Outgoings
  class BaseOutgoing
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :payment_date, :date
    attribute :amount, :decimal
    attribute :client_id, :string

    validates :payment_date, date: {
      before: proc { Time.zone.tomorrow }, message: :not_in_the_future
    }
  end
end
