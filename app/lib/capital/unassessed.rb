module Capital
  class Unassessed < Base
    def initialize(submission_date:, level_of_help:)
      super(
        PersonCapitalSubtotals.unassessed(vehicles: [],
                                          properties: []),
      )
      @level_of_help = level_of_help
      @submission_date = submission_date
    end

    def partner_capital_subtotals
      PersonCapitalSubtotals.unassessed(vehicles: [], properties: [])
    end

    def eligibilities(proceeding_types)
      Creators::CapitalEligibilityCreator.unassessed proceeding_types:,
                                                     submission_date: @submission_date,
                                                     level_of_help: @level_of_help
    end

    def combined_assessed_capital
      0
    end

    def capital_contribution(_proceeding_types)
      0
    end
  end
end
