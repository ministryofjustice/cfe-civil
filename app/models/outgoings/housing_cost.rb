module Outgoings
  class HousingCost < BaseOutgoing
    extend EnumHash

    enum housing_cost_type: enum_hash_for(:rent, :mortgage, :board_and_lodging)

    def allowable_amount
      board_and_lodging? ? (amount / 2).round(2) : amount
    end

    def board_and_lodging?
      housing_cost_type == "board_and_lodging"
    end
  end
end
