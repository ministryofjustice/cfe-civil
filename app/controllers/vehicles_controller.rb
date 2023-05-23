class VehiclesController < CreationController
  before_action :load_assessment

  def create
    swagger_validate_and_render "vehicles", vehicles_params, lambda {
      Creators::VehicleCreator.call(
        vehicles_params:,
        capital_summary: @assessment.applicant_capital_summary,
      )
    }
  end

private

  def vehicles_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
