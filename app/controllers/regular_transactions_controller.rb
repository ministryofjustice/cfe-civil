class RegularTransactionsController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::RegularTransactionsCreator.call(
      assessment_id: params[:assessment_id],
      regular_transaction_params: request.raw_post,
    )
  end
end
