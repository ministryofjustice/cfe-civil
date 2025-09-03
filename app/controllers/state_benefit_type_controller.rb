class StateBenefitTypeController < ApplicationController
  def index
    raise "Katharine testing" if Rails.env.production?

    render json: StateBenefitType.as_cfe_json
  end
end
