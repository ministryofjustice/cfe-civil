class CashTransactionsController < CreationController
  before_action :load_assessment

  def create
    swagger_validate_and_render("cash_transactions", cash_transaction_params, lambda {
      Creators::CashTransactionsCreator.call(
        submission_date: @assessment.submission_date,
        gross_income_summary: @assessment.applicant_gross_income_summary,
        cash_transaction_params:,
      )
    })
  end

private

  def cash_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
