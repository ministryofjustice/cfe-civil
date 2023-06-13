module Assessors
  class CapitalItemAssessor
    Result = Data.define(:value)
    CapitalData = Data.define(:capital_item, :result)
  end
end
