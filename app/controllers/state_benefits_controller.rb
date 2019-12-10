class StateBenefitsController < ApplicationController
  resource_description do
    short 'Add state benefits to an assessment'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicants'state benefits to an assessment.
    END_OF_TEXT
  end

  api :POST, 'assessments/:assessment_id/state_benefit', 'Create state benefit'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :state_benefits, Array, desc: 'Collection of state benefits' do
    param :name, String, required: true, desc: 'The state benefit name'
    param :payments, Array, desc: 'Collection of payment dates and amounts' do
      param :date, Date, date_option: :today_or_older, required: true, desc: 'The date payment received'
      param :amount, :currency, 'Amount of payment'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Object
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if creation_service.success?
      render_success objects: creation_service.result
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= StateBenefitsCreationService.call(
      assessment_id: params[:assessment_id],
      state_benefits: state_benefit_params
    )
  end

  def state_benefit_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
