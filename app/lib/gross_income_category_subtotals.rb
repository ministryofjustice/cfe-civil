GrossIncomeCategorySubtotals = Struct.new(:category, :bank, :cash, :regular, keyword_init: true) do
  def all_sources
    bank + cash + regular
  end
end
