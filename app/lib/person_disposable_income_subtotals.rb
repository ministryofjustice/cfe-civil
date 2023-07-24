class PersonDisposableIncomeSubtotals
  class << self
    def blank
      new(Collators::OutgoingsCollator::Result.blank,
          0,
          Collators::RegularOutgoingsCollator::Result.blank,
          Collators::DisposableIncomeCollator::Result.blank)
    end
  end

  attr_reader :partner_allowance

  def initialize(outgoings, partner_allowance, regular, disposable)
    @outgoings = outgoings
    @partner_allowance = partner_allowance
    @regular = regular
    @disposable = disposable
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

  def rent_or_mortgage_bank
    @outgoings.rent_or_mortgage_bank
  end

  def rent_or_mortgage_cash
    @disposable.rent_or_mortgage_cash
  end

  def rent_or_mortgage_all_sources
    rent_or_mortgage_bank + rent_or_mortgage_cash + @regular.rent_or_mortgage_regular
  end
end
