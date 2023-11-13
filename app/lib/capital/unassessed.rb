module Capital
  class Unassessed < Base
    def initialize(applicant_capitals:, submission_date:, level_of_help:)
      super(
        PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(applicant_capitals.vehicles),
                                          properties: unassessed_properties(applicant_capitals.properties)),
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

  private

    def unassessed_vehicles(vehicles)
      (vehicles || []).map do |vehicle|
        Calculators::VehicleCalculator::VehicleData.new(vehicle:, result: Calculators::VehicleCalculator::Result.new(assessed_value: 0, included_in_assessment: false))
      end
    end

    def unassessed_properties(properties)
      (properties || []).map do |property|
        Calculators::PropertyCalculator::PropertyData.new(property:, result: Calculators::PropertyCalculator::Result.blank)
      end
    end
  end
end
