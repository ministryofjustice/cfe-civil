class PersonCapitalSubtotals
  # This (and other similar classes) has 2 use cases: (a) fully-populated and (b) blank
  # This structure helps enforce that so that e.g. tests are updated when the structure changes
  class << self
    def blank
      new(total_vehicle: 0.0, total_liquid: 0,
          total_mortgage_allowance: 0.0, total_non_liquid: 0.0,
          disputed_property_disregard: 0.0, pensioner_capital_disregard: 0.0,
          properties: [], disputed_non_property_disregard: 0.0, disputed_non_property_capital: 0.0, non_disputed_non_property_capital: 0.0)
    end
  end

  def initialize(total_vehicle:, total_liquid:,
                 total_mortgage_allowance:, total_non_liquid:,
                 disputed_property_disregard:, pensioner_capital_disregard:,
                 properties:, disputed_non_property_disregard:,
                 disputed_non_property_capital:, non_disputed_non_property_capital:)
    @total_vehicle = total_vehicle
    @total_liquid = total_liquid
    @total_mortgage_allowance = total_mortgage_allowance
    @total_non_liquid = total_non_liquid
    @pensioner_capital_disregard = pensioner_capital_disregard
    @disputed_property_disregard = disputed_property_disregard
    @disputed_non_property_disregard = disputed_non_property_disregard
    @properties = properties
    @disputed_non_property_capital = disputed_non_property_capital
    @non_disputed_non_property_capital = non_disputed_non_property_capital
  end

  attr_reader :total_vehicle,
              :total_liquid,
              :total_mortgage_allowance,
              :total_non_liquid,
              :pensioner_capital_disregard,
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

  def total_property
    @properties.sum(&:assessed_equity)
  end

  def total_non_disputed_capital
    @properties.reject(&:subject_matter_of_dispute).sum(&:assessed_equity) + @non_disputed_non_property_capital
  end

  def total_disputed_capital
    @properties.select(&:subject_matter_of_dispute).sum(&:assessed_equity) + @disputed_non_property_capital
  end
end
