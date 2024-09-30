class OtherAssetsHandler < SubtotalsBase
  # rubocop:disable Lint/MissingSuper
  def initialize(liquid_capital_items:, non_liquid_capital_items:)
    @liquid_capital_items = liquid_capital_items
    @non_liquid_capital_items = non_liquid_capital_items
  end
  # rubocop:enable Lint/MissingSuper

  def total_liquid
    @liquid_capital_items.map(&:result).sum(&:value)
  end

  def total_non_liquid
    @non_liquid_capital_items.map(&:result).sum(&:value)
  end

  def total
    total_liquid + total_non_liquid
  end

  def liquid_capital_items
    @liquid_capital_items.map(&:capital_item)
  end

  def non_liquid_capital_items
    @non_liquid_capital_items.map(&:capital_item)
  end

  def total_disputed
    disputed_liquid_items.sum(&:value) + disputed_non_liquid_items.sum(&:value)
  end

  def disputed_items
    disputed_liquid_items + disputed_non_liquid_items
  end

  def total_undisputed
    undisputed_liquid_items.sum(&:value) + undisputed_non_liquid_items.sum(&:value)
  end

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
