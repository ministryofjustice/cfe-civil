class PersonCapitalSubtotals
  def initialize(total_vehicle: 0.0, total_liquid: 0,
                 total_mortgage_allowance: 0.0, total_non_liquid: 0.0, total_property: 0.0,
                 disputed_property_disregard: 0.0, pensioner_capital_disregard: 0.0,
                 main_home: PropertySubtotals.new,
                 additional_properties: [], disputed_non_property_disregard: 0.0)
    @total_vehicle = total_vehicle
    @total_liquid = total_liquid
    @total_mortgage_allowance = total_mortgage_allowance
    @total_non_liquid = total_non_liquid
    @total_property = total_property
    @disputed_property_disregard = disputed_property_disregard
    @pensioner_capital_disregard = pensioner_capital_disregard
    @main_home = main_home
    @additional_properties = additional_properties
    @disputed_non_property_disregard = disputed_non_property_disregard
  end

  attr_reader :total_vehicle,
              :total_liquid,
              :total_mortgage_allowance,
              :total_non_liquid,
              :total_property,
              :pensioner_capital_disregard,
              :main_home,
              :additional_properties,
              :disputed_non_property_disregard,
              :disputed_property_disregard

  def assessed_capital
    [total_capital_with_smod - pensioner_capital_disregard, 0].max
  end

  def total_capital_with_smod
    total_capital - disputed_non_property_disregard
  end

  def pensioner_disregard_applied
    [pensioner_capital_disregard, total_capital_with_smod].min
  end

  def total_capital
    total_liquid + total_non_liquid + total_vehicle + total_property
  end

  def subject_matter_of_dispute_disregard
    disputed_non_property_disregard + @disputed_property_disregard
  end

  def total_non_disputed_capital
    total_capital - subject_matter_of_dispute_disregard
  end
end
