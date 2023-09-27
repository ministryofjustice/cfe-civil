GrossIncomeCategorySubtotals = Data.define(:category, :bank, :cash, :regular) do
  def all_sources
    bank + cash + regular
  end
end
