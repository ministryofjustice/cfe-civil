class PersonCapitalSubtotals
  # This (and other similar classes) has 2 use cases: (a) fully-populated and (b) blank
  # This structure helps enforce that so that e.g. tests are updated when the structure changes
  class << self
    def unassessed(vehicles:, properties:)
      new(vehicles:,
          properties:,
          liquid_capital_items: [], non_liquid_capital_items: [],
          total_mortgage_allowance: 0.0,
          pensioner_capital_disregard: 0.0,
          maximum_subject_matter_of_dispute_disregard: 0.0)
    end
  end

  def initialize(vehicles:,
                 properties:,
                 liquid_capital_items:,
                 non_liquid_capital_items:,
                 total_mortgage_allowance:,
                 pensioner_capital_disregard:,
                 maximum_subject_matter_of_dispute_disregard:)
    @disputed_vehicles = vehicles.select { |v| v.vehicle.subject_matter_of_dispute }
    @undisputed_vehicles = vehicles.reject { |v| v.vehicle.subject_matter_of_dispute }
    @total_mortgage_allowance = total_mortgage_allowance
    @pensioner_capital_disregard = pensioner_capital_disregard
    @properties = properties
    @liquid_capital_items = liquid_capital_items
    @non_liquid_capital_items = non_liquid_capital_items
    @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
  end

  attr_reader :total_mortgage_allowance,
              :pensioner_capital_disregard,
              :maximum_subject_matter_of_dispute_disregard

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
    main_home = @properties.detect { |p| p.property.main_home }
    (main_home.presence || Assessors::PropertyAssessor::PropertyData.blank_main_home)
  end

  def additional_properties
    @properties.reject { |p| p.property.main_home }
  end

  # subject matter of dispute is calculated earlier for property, so this value already includes SMOD disregards
  def total_property
    @properties.map(&:result).sum(&:assessed_equity)
  end

  def total_non_disputed_capital
    @properties.reject { |p| p.property.subject_matter_of_dispute }.map(&:result).sum(&:assessed_equity) +
      undisputed_liquid_items.sum(&:value) +
      undisputed_non_liquid_items.sum(&:value) +
      @undisputed_vehicles.map(&:result).sum(&:assessed_value)
  end

  def total_disputed_capital
    @properties.select { |p| p.property.subject_matter_of_dispute }.map(&:result).sum(&:assessed_equity) +
      disputed_liquid_items.sum(&:value) +
      disputed_non_liquid_items.sum(&:value) +
      @disputed_vehicles.map(&:result).sum(&:assessed_value) - disputed_non_property_disregard
  end

  def disputed_non_property_disregard
    Calculators::SubjectMatterOfDisputeDisregardCalculator.call(
      disputed_capital_items: disputed_liquid_items + disputed_non_liquid_items,
      disputed_vehicles: @disputed_vehicles.map(&:result),
      maximum_disregard: maximum_smod_disregard,
    )
  end

  def disputed_property_disregard
    @properties.map(&:result).sum(&:smod_allowance)
  end

  def maximum_smod_disregard
    maximum_subject_matter_of_dispute_disregard - disputed_property_disregard
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
