module Capital
  class UnassessedWithPartner < Unassessed
    attr_reader :partner_capital_subtotals

    def initialize(applicant_capitals:, partner_capitals:, submission_date:, level_of_help:)
      super(
        applicant_capitals:,
        submission_date:,
        level_of_help:
      )
      @partner_capital_subtotals = PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(partner_capitals.vehicles),
                                                                     properties: unassessed_properties(partner_capitals.properties))
    end
  end
end
