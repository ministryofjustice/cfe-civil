class PersonCapitalSubtotals
  # This (and other similar classes) has 2 use cases: (a) fully-populated and (b) blank
  # This structure helps enforce that so that e.g. tests are updated when the structure changes
  class << self
    def unassessed(vehicles:, properties:)
      new(vehicles:,
          properties:,
          liquid_capital_items: [], non_liquid_capital_items: [],
          pensioner_capital_disregard: 0.0,
          maximum_subject_matter_of_dispute_disregard: 0.0)
    end
  end

  def initialize(vehicles:, properties:, liquid_capital_items:, non_liquid_capital_items:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:)
    @vehicle_subtotals = vehicles
    @property_subtotals = properties
    @other_assets_handler = OtherAssetsHandler.new(liquid_capital_items:, non_liquid_capital_items:)
    @pensioner_capital_disregard = pensioner_capital_disregard
    @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
  end

  attr_reader :pensioner_capital_disregard,
              :maximum_subject_matter_of_dispute_disregard,
              :vehicle_subtotals,
              :property_subtotals,
              :other_assets_handler

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
    other_assets_handler.total + vehicle_subtotals.total_vehicle + property_subtotals.total_property
  end

  def subject_matter_of_dispute_disregard
    disputed_non_property_disregard + property_subtotals.disputed_property_disregard
  end

  def total_non_disputed_capital
    property_subtotals.total_undisputed +
      other_assets_handler.total_undisputed +
      vehicle_subtotals.undisputed_result.sum(&:assessed_value)
  end

  def total_disputed_capital
    property_subtotals.total_disputed +
      other_assets_handler.total_disputed +
      vehicle_subtotals.disputed_result.sum(&:assessed_value) - disputed_non_property_disregard
  end

  def disputed_non_property_disregard
    Calculators::SubjectMatterOfDisputeDisregardCalculator.call(
      disputed_capital_items: other_assets_handler.disputed_items,
      disputed_vehicles: vehicle_subtotals.disputed_result,
      maximum_disregard: maximum_smod_disregard,
    )
  end

  def maximum_smod_disregard
    maximum_subject_matter_of_dispute_disregard - property_subtotals.disputed_property_disregard
  end
end
