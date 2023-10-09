CapitalsData = Data.define(:vehicles, :liquid_capital_items, :non_liquid_capital_items, :main_home, :additional_properties) do
  def properties
    ([main_home.presence] + additional_properties).compact
  end
end
