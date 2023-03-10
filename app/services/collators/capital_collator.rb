module Collators
  class CapitalCollator
    class << self
      def call(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:)
        new(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:).call
      end
    end

    def initialize(submission_date:, capital_summary:, pensioner_capital_disregard:, maximum_subject_matter_of_dispute_disregard:, level_of_representation:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @pensioner_capital_disregard = pensioner_capital_disregard
      @maximum_subject_matter_of_dispute_disregard = maximum_subject_matter_of_dispute_disregard
      @level_of_representation = level_of_representation
    end

    def call
      perform_assessments

      PersonCapitalSubtotals.new(
        total_liquid: @liquid_capital,
        total_non_liquid: @non_liquid_capital,
        total_vehicle: @vehicles,
        total_mortgage_allowance: property_maximum_mortgage_allowance_threshold,
        total_property: @property,
        pensioner_capital_disregard: @pensioner_capital_disregard,
        subject_matter_of_dispute_disregard: @subject_matter_of_dispute_disregard,
        total_capital: @total_capital,
        assessed_capital: @assessed_capital,
      )
    end

  private

    def perform_assessments
      @liquid_capital = Assessors::LiquidCapitalAssessor.call(@capital_summary)
      @non_liquid_capital = Assessors::NonLiquidCapitalAssessor.call(@capital_summary)
      @property = Calculators::PropertyCalculator.call(submission_date: @submission_date,
                                                       capital_summary: @capital_summary,
                                                       level_of_representation: @level_of_representation)
      @vehicles = Assessors::VehicleAssessor.call(@capital_summary.vehicles, @submission_date)
      @subject_matter_of_dispute_disregard = Calculators::SubjectMatterOfDisputeDisregardCalculator.new(
        capital_summary: @capital_summary,
        maximum_disregard: @maximum_subject_matter_of_dispute_disregard,
      ).value
      @total_capital = @liquid_capital + @non_liquid_capital + @vehicles + @property
      @assessed_capital = @total_capital - @pensioner_capital_disregard - @subject_matter_of_dispute_disregard
    end

    def property_maximum_mortgage_allowance_threshold
      Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end
  end
end
