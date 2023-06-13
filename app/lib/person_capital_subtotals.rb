class PersonCapitalSubtotals
  # This (and other similar classes) has 2 use cases: (a) fully-populated and (b) blank
  # This structure helps enforce that so that e.g. tests are updated when the structure changes
  class << self
    def blank
      new(vehicles: [],
          properties: [],
          liquid_capital_items: [], non_liquid_capital_items: [],
          total_mortgage_allowance: 0.0,
          disputed_property_disregard: 0.0, pensioner_capital_disregard: 0.0,
          maximum_smod_disregard: 0.0)
    end

    def unassessed(disputed_vehicles:, non_disputed_vehicles:)
      new(disputed_vehicles:, non_disputed_vehicles:, total_liquid: 0,
          total_mortgage_allowance: 0.0, total_non_liquid: 0.0,
          disputed_property_disregard: 0.0, pensioner_capital_disregard: 0.0,
          properties: [], disputed_non_property_disregard: 0.0, disputed_non_property_capital: 0.0, non_disputed_non_property_capital: 0.0)
    end
  end

  def initialize(vehicles:,
                 properties:,
                 liquid_capital_items:,
                 non_liquid_capital_items:,
                 total_mortgage_allowance:,
                 disputed_property_disregard:, pensioner_capital_disregard:,
                 maximum_smod_disregard:)
    @disputed_vehicles = vehicles.select { |v| v.vehicle.subject_matter_of_dispute }
    @undisputed_vehicles = vehicles.reject { |v| v.vehicle.subject_matter_of_dispute }
    @total_mortgage_allowance = total_mortgage_allowance
    @pensioner_capital_disregard = pensioner_capital_disregard
    @disputed_property_disregard = disputed_property_disregard
    @properties = properties
    @liquid_capital_items = liquid_capital_items
    @non_liquid_capital_items = non_liquid_capital_items
    @maximum_smod_disregard = maximum_smod_disregard
  end

  attr_reader :total_mortgage_allowance,
              :pensioner_capital_disregard,
              :disputed_property_disregard

  def total_liquid
    @liquid_capital_items.map(&:result).sum(&:value)
  end

  def total_non_liquid
    @non_liquid_capital_items.map(&:result).sum(&:value)
  end

  def vehicles
    @disputed_vehicles + @undisputed_vehicles
  end

  def total_vehicle
    vehicles.map(&:result).sum(&:assessed_value)
  end

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
    disputed_non_property_disregard + disputed_property_disregard
  end

  def main_home
    main_home = @properties.detect(&:main_home)
    if main_home.present?
      PropertySubtotals.new(main_home)
    else
      PropertySubtotals.new
    end
  end

  def additional_properties
    @properties.reject(&:main_home).map { |p| PropertySubtotals.new(p) }
  end

  # subject matter of dispute is calculated earlier for property, so this value already includes SMOD disregards
  def total_property
    @properties.sum(&:assessed_equity)
  end

  def total_non_disputed_capital
    @properties.reject(&:subject_matter_of_dispute).sum(&:assessed_equity) +
      undisputed_liquid_items.sum(&:value) +
      undisputed_non_liquid_items.sum(&:value) +
      @undisputed_vehicles.map(&:result).sum(&:assessed_value)
  end

  def total_disputed_capital
    @properties.select(&:subject_matter_of_dispute).sum(&:assessed_equity) +
      disputed_liquid_items.sum(&:value) +
      disputed_non_liquid_items.sum(&:value) +
      @disputed_vehicles.map(&:result).sum(&:assessed_value) - disputed_non_property_disregard
  end

  def disputed_non_property_disregard
    Calculators::SubjectMatterOfDisputeDisregardCalculator.call(
      disputed_capital_items: disputed_liquid_items + disputed_non_liquid_items,
      disputed_vehicles: @disputed_vehicles.map(&:result),
      maximum_disregard: @maximum_smod_disregard,
    )
  end

private

  def disputed_liquid_items
    @liquid_capital_items.select { |c| c.capital_item.subject_matter_of_dispute }.map(&:result)
  end

  def undisputed_liquid_items
    @liquid_capital_items.reject { |c| c.capital_item.subject_matter_of_dispute }.map(&:result)
  end

  def disputed_non_liquid_items
    @non_liquid_capital_items.select { |c| c.capital_item.subject_matter_of_dispute }.map(&:result)
  end

  def undisputed_non_liquid_items
    @non_liquid_capital_items.reject { |c| c.capital_item.subject_matter_of_dispute }.map(&:result)
  end
end
