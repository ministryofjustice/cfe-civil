class UnassessedCapitalResult
  def applicant_capital_subtotals
    PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
  end

  def partner_capital_subtotals
    PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
  end

  def combined_assessed_capital
    0
  end

  def capital_contribution(_proceeding_types)
    0
  end
end
