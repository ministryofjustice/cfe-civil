module Calculators
  class CapitalItemCalculator
    Result = Data.define(:value)
    CapitalData = Data.define(:capital_item, :result)
  end
end
