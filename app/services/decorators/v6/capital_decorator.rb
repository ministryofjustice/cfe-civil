module Decorators
  module V6
    class CapitalDecorator
      def initialize(capital_subtotals)
        @capital_subtotals = capital_subtotals
      end

      def as_json
        payload
      end

    private

      def payload
        {
          capital_items:,
        }
      end

      def capital_items
        {
          liquid: liquid_items,
          non_liquid: non_liquid_items,
          vehicles:,
          properties:,
        }
      end

      def properties
        {
          main_home: PropertyDecorator.new(@capital_subtotals.property_handler.main_home.property, @capital_subtotals.property_handler.main_home.result).as_json,
          additional_properties:,
        }
      end

      def liquid_items
        @capital_subtotals.other_assets_handler.liquid_capital_items.map { |i| CapitalItemDecorator.new(i).as_json }
      end

      def non_liquid_items
        @capital_subtotals.other_assets_handler.non_liquid_capital_items.map { |ni| CapitalItemDecorator.new(ni).as_json }
      end

      def additional_properties
        @capital_subtotals.property_handler.additional_properties.map { |p| PropertyDecorator.new(p.property, p.result).as_json }
      end

      def vehicles
        @capital_subtotals.vehicle_handler.all_vehicles.map { |v| VehicleDecorator.new(v.vehicle, v.result).as_json }
      end
    end
  end
end
