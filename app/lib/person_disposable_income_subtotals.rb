class PersonDisposableIncomeSubtotals
  BlankDependantAllowance = Data.define(:under_16, :over_16)
  BlankOutgoings = Data.define(:dependant_allowance, :child_care)
  class << self
    def blank
      result = BlankDependantAllowance.new(under_16: 0, over_16: 0)
      new(BlankOutgoings.new(dependant_allowance: result,
                             child_care: Collators::ChildcareCollator::Result.new(bank: 0, cash: 0)),
          0,
          Collators::RegularOutgoingsCollator::Result.new(child_care_regular: 0))
    end
  end

  attr_reader :partner_allowance

  def initialize(outgoings, partner_allowance, regular)
    @outgoings = outgoings
    @partner_allowance = partner_allowance
    @regular = regular
  end

  def dependant_allowance_over_16
    @outgoings.dependant_allowance.over_16
  end

  def dependant_allowance_under_16
    @outgoings.dependant_allowance.under_16
  end

  def dependant_allowance
    dependant_allowance_over_16 + dependant_allowance_under_16
  end

  def child_care_bank
    @outgoings.child_care.bank
  end

  def child_care_cash
    @outgoings.child_care.cash
  end

  def child_care_all_sources
    @outgoings.child_care.bank + @outgoings.child_care.cash + @regular.child_care_regular
  end
end
