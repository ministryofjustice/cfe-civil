class PersonDisposableIncomeSubtotals
  BlankResult = Data.define(:dependant_allowance_under_16, :dependant_allowance_over_16)
  class << self
    def blank
      result = BlankResult.new(dependant_allowance_under_16: 0, dependant_allowance_over_16: 0)
      new(result, 0)
    end
  end

  attr_reader :dependant_allowance_under_16, :dependant_allowance_over_16, :partner_allowance

  def initialize(outgoings, partner_allowance)
    @dependant_allowance_under_16 = outgoings.dependant_allowance_under_16
    @dependant_allowance_over_16 = outgoings.dependant_allowance_over_16
    @partner_allowance = partner_allowance
  end

  def dependant_allowance
    dependant_allowance_under_16 + dependant_allowance_over_16
  end
end
