class VehicleHandler
  def initialize(vehicles)
    @vehicles = vehicles
  end

  def disputed
    @vehicles.select { |v| v.vehicle.subject_matter_of_dispute }
  end

  def undisputed
    @vehicles.reject { |v| v.vehicle.subject_matter_of_dispute }
  end

  def disputed_result
    disputed.map(&:result)
  end

  def undisputed_result
    undisputed.map(&:result)
  end

  def all_vehicles
    disputed + undisputed
  end

  def total_vehicle
    all_vehicles.map(&:result).sum(&:assessed_value)
  end
end
