class PersonDisposableIncomeSubtotals
  class << self
    def blank
      new(PersonGrossIncomeSubtotals.blank,
          Collators::OutgoingsCollator::Result.blank,
          0,
          Collators::RegularOutgoingsCollator::Result.blank,
          Collators::DisposableIncomeCollator::Result.blank)
    end
  end

  attr_reader :partner_allowance

  def initialize(gross_income_subtotals, outgoings, partner_allowance, regular, disposable)
    @gross_income_subtotals = gross_income_subtotals
    @outgoings = outgoings
    @partner_allowance = partner_allowance
    @regular = regular
    @disposable = disposable
  end

  def total_disposable_income
    @gross_income_subtotals.total_gross_income - total_outgoings_and_allowances
  end

  def total_outgoings_and_allowances
    [net_housing_costs,
     dependant_allowance_under_16,
     dependant_allowance_over_16,
     monthly_bank_transactions_total,
     monthly_regular_outgoings_total,
     monthly_cash_transactions_total].sum -
      [@gross_income_subtotals.employment_income_subtotals.fixed_employment_allowance,
       @gross_income_subtotals.employment_income_subtotals.employment_income_deductions].sum +
      @partner_allowance
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

  def legal_aid_bank
    @outgoings.legal_aid_bank
  end

  def legal_aid_cash
    @disposable.legal_aid_cash
  end

  def legal_aid_all_sources
    legal_aid_bank + legal_aid_cash + @regular.legal_aid_regular
  end

  def housing_benefit
    @outgoings.housing_costs.housing_benefit
  end

  def gross_housing_costs
    @outgoings.housing_costs.gross_housing_costs
  end

  def net_housing_costs
    @outgoings.housing_costs.net_housing_costs
  end

  def maintenance_out_bank
    @outgoings.maintenance_out_bank
  end

  def maintenance_out_cash
    @disposable.maintenance_out_cash
  end

  def maintenance_out_all_sources
    maintenance_out_bank + maintenance_out_cash + @regular.maintenance_out_regular
  end

private

  def monthly_cash_transactions_total
    [maintenance_out_cash, child_care_cash, legal_aid_cash].sum
  end

  def monthly_bank_transactions_total
    [@outgoings.child_care.bank, @outgoings.maintenance_out_bank, @outgoings.legal_aid_bank].sum
  end

  # ** :rent_or_mortgage has already been added to totals by the
  # HousingCostCollator/HousingCostCalculator and DisposableIncomeCollator :(
  def monthly_regular_outgoings_total
    [@regular.legal_aid_regular, @regular.child_care_regular, @regular.maintenance_out_regular].sum
  end
end
