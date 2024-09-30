class PropertySubtotals < SubtotalsBase
  attr_reader :total_mortgage_allowance

  # rubocop:disable Lint/MissingSuper
  def initialize(properties:, total_mortgage_allowance: 0.0)
    @properties = properties
    @total_mortgage_allowance = total_mortgage_allowance
  end
  # rubocop:enable Lint/MissingSuper

  def main_home
    main_home = @properties.detect { |p| p.property.main_home }
    main_home.presence || Calculators::PropertyCalculator::PropertyData.blank_main_home
  end

  def additional_properties
    @properties.reject { |p| p.property.main_home }
  end

  # subject matter of dispute is calculated earlier for property, so this value already includes SMOD disregards
  def total_property
    @properties.map(&:result).sum(&:assessed_equity)
  end

  def total_undisputed
    @properties.reject { |p| p.property.subject_matter_of_dispute }.map(&:result).sum(&:assessed_equity)
  end

  def total_disputed
    @properties.select { |p| p.property.subject_matter_of_dispute }.map(&:result).sum(&:assessed_equity)
  end

  def disputed_property_disregard
    @properties.map(&:result).sum(&:smod_allowance)
  end
end
