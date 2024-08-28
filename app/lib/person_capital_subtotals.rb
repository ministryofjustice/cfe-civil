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
    @vehicle_handler = VehicleHandler.new(vehicles)
    @property_handler = PropertyHandler.new(properties:, total_mortgage_allowance:)
    @pensioner_capital_disregard = pensioner_capital_disregard
    @liquid_capital_items = liquid_capital_items
    @non_liquid_capital_items = non_liquid_capital_items
    @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
  end

  attr_reader :pensioner_capital_disregard,
              :maximum_subject_matter_of_dispute_disregard,
              :vehicle_handler,
              :property_handler

  def total_liquid
    @liquid_capital_items.map(&:result).sum(&:value)
  end

  def total_non_liquid
    @non_liquid_capital_items.map(&:result).sum(&:value)
  end

  def assessed_capital
    [total_capital_with_smod - pensioner_capital_disregard, 0].max
  end

  # relevant to this capital class
  def total_capital_with_smod
    total_capital - disputed_non_property_disregard
  end

  def pensioner_disregard_applied
    [pensioner_capital_disregard, total_capital_with_smod].min
  end

  # this is relevant to the capital class
  def total_capital
    total_liquid + total_non_liquid + vehicle_handler.total_vehicle + property_handler.total_property
  end

  def subject_matter_of_dispute_disregard
    disputed_non_property_disregard + property_handler.disputed_property_disregard
  end

  def total_non_disputed_capital
    property_handler.total_undisputed +
      undisputed_liquid_items.sum(&:value) +
      undisputed_non_liquid_items.sum(&:value) +
      vehicle_handler.undisputed_result.sum(&:assessed_value)
  end

  def total_disputed_capital
    property_handler.total_disputed +
      disputed_liquid_items.sum(&:value) +
      disputed_non_liquid_items.sum(&:value) +
      vehicle_handler.disputed_result.sum(&:assessed_value) - disputed_non_property_disregard
  end

  # can beloing in this capital class
  def disputed_non_property_disregard
    Calculators::SubjectMatterOfDisputeDisregardCalculator.call(
      disputed_capital_items: disputed_liquid_items + disputed_non_liquid_items,
      disputed_vehicles: vehicle_handler.disputed_result,
      maximum_disregard: maximum_smod_disregard,
    )
  end

  def maximum_smod_disregard
    maximum_subject_matter_of_dispute_disregard - property_handler.disputed_property_disregard
  end

  def liquid_capital_items
    @liquid_capital_items.map(&:capital_item)
  end

  def non_liquid_capital_items
    @non_liquid_capital_items.map(&:capital_item)
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
