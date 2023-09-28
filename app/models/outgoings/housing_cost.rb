module Outgoings
  class HousingCost < BaseOutgoing
    attribute :housing_cost_type, :string

    def allowable_amount
      board_and_lodging? ? (amount / 2).round(2) : amount
    end

    def board_and_lodging?
      housing_cost_type == "board_and_lodging"
    end
  end
end
