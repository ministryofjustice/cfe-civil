module Collators
  class LegalAidCollator
    class << self
      def call(disposable_income_summary)
        Calculators::MonthlyEquivalentCalculator.call(
          collection: disposable_income_summary.legal_aid_outgoings,
        )
      end
    end
  end
end
