module Collators
  class LegalAidCollator
    class << self
      def call(legal_aid_outgoings)
        Calculators::MonthlyEquivalentCalculator.call(collection: legal_aid_outgoings)
      end
    end
  end
end
