module Capital
  class Subtotals < Base
    attr_reader :combined_assessed_capital

    def initialize(applicant_capital_subtotals:, partner_capital_subtotals:, combined_assessed_capital:,
                   proceeding_types:, submission_date:, level_of_help:)
      super(applicant_capital_subtotals:, partner_capital_subtotals:, proceeding_types:, submission_date:, level_of_help:)
      @combined_assessed_capital = combined_assessed_capital
    end

    def eligibilities
      Creators::CapitalEligibilityCreator.call proceeding_types: @proceeding_types,
                                               submission_date: @submission_date,
                                               level_of_help: @level_of_help,
                                               assessed_capital: combined_assessed_capital
    end

    def capital_contribution
      threshold = eligibilities.map(&:lower_threshold).min
      [0, combined_assessed_capital - threshold].max
    end
  end
end
