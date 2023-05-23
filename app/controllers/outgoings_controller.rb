class OutgoingsController < CreationController
  before_action :load_assessment

  def create
    swagger_validate_and_render "outgoings", outgoings_params, lambda {
      Creators::OutgoingsCreator.call(
        outgoings_params:,
        disposable_income_summary: @assessment.applicant_disposable_income_summary,
      )
    }
  end

private

  def outgoings_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
