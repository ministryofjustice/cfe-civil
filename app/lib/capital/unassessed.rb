module Capital
  class Unassessed < Base
    def initialize(applicant_capitals:, partner_capitals:, proceeding_types:, submission_date:, level_of_help:)
      super(
        applicant_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(applicant_capitals.vehicles),
                                                                       properties: unassessed_properties(applicant_capitals.properties)),
        partner_capital_subtotals: PersonCapitalSubtotals.unassessed(vehicles: unassessed_vehicles(partner_capitals&.vehicles),
                                                                     properties: unassessed_properties(partner_capitals&.properties)),
        proceeding_types:,
        submission_date:,
        level_of_help:
      )
    end

    def eligibilities
      Creators::CapitalEligibilityCreator.unassessed proceeding_types: @proceeding_types,
                                                     submission_date: @submission_date,
                                                     level_of_help: @level_of_help
    end

    def combined_assessed_capital
      0
    end

    def capital_contribution
      0
    end

  private

    def unassessed_vehicles(vehicles)
      (vehicles || []).map do |vehicle|
        Assessors::VehicleAssessor::VehicleData.new(vehicle:, result: Assessors::VehicleAssessor::Result.new(assessed_value: 0, included_in_assessment: false))
      end
    end

    def unassessed_properties(properties)
      (properties || []).map do |property|
        Assessors::PropertyAssessor::PropertyData.new(property:, result: Assessors::PropertyAssessor::Result.blank)
      end
    end
  end
end
