Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  resources :state_benefit_type, only: [:index]

  root to: "main#index"

  namespace :v6 do
    # single-shot version of the above POSTxN, GET sequence
    resources :assessments, only: [:create]
  end

  get "ping", to: "status#ping", format: :json
  get "healthcheck", to: "status#status", format: :json
  get "status", to: "status#status", format: :json
  get "state_benefit_type", to: "state_benefit_type#index", format: :json
end
