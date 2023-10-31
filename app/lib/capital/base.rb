module Capital
  class Base
    attr_reader :applicant_capital_subtotals

    def initialize(applicant_capital_subtotals)
      @applicant_capital_subtotals = applicant_capital_subtotals
    end
  end
end
