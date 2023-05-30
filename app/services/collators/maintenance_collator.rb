module Collators
  class MaintenanceCollator
    class << self
      def call(maintenance_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: maintenance_outgoings)
      end
    end
  end
end
