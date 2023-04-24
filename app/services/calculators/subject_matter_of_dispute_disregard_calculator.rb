# WARNING: This calculator assumes that the assessed value/equity of all disputed properties and vehicles
# has already been calculated. If this is not the case, it will produce inaccurate results.
module Calculators
  class SubjectMatterOfDisputeDisregardCalculator
    class << self
      def call(disputed_capital_items:, disputed_vehicles:, maximum_disregard:)
        total_disputed_asset_value = disputed_capital_value(disputed_capital_items) +
          disputed_vehicle_value(disputed_vehicles)

        if total_disputed_asset_value.positive? && maximum_disregard.nil?
          raise "SMOD assets listed but no threshold data found"
        end

        [total_disputed_asset_value, maximum_disregard].compact.min
      end

    private

      def disputed_capital_value(disputed_capital_items)
        disputed_capital_items.sum(&:value)
      end

      def disputed_vehicle_value(disputed_vehicles)
        disputed_vehicles.sum(&:assessed_value)
      end
    end
  end
end
