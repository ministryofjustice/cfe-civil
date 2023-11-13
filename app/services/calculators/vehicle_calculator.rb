module Calculators
  class VehicleCalculator
    Result = Data.define(:assessed_value, :included_in_assessment)
    VehicleData = Data.define(:vehicle, :result)

    class << self
      def call(vehicles, submission_date)
        vehicles.map { VehicleData.new(vehicle: _1, result: assess(_1, submission_date)) }
      end

    private

      def assess(vehicle, submission_date)
        if vehicle.in_regular_use?
          assess_in_regular_use(vehicle, submission_date)
        else
          assess_not_in_regular_use(vehicle)
        end
      end

      def assess_in_regular_use(vehicle, submission_date)
        net_value = vehicle.value - vehicle.loan_amount_outstanding
        if too_old_to_count(vehicle, submission_date) || net_value <= vehicle_disregard(submission_date)
          Result.new(assessed_value: 0, included_in_assessment: false).freeze
        else
          Result.new(assessed_value: net_value - vehicle_disregard(submission_date), included_in_assessment: true).freeze
        end
      end

      def assess_not_in_regular_use(vehicle)
        Result.new(assessed_value: vehicle.value, included_in_assessment: true).freeze
      end

      def too_old_to_count(vehicle, submission_date)
        vehicle.age_in_months(submission_date) >= vehicle_out_of_scope_age(submission_date)
      end

      def vehicle_out_of_scope_age(submission_date)
        Threshold.value_for(:vehicle_out_of_scope_months, at: submission_date)
      end

      def vehicle_disregard(submission_date)
        Threshold.value_for(:vehicle_disregard, at: submission_date)
      end
    end
  end
end
