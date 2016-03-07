Rails.application.routes.draw do
  root "site#index"

  get "/auth/fitbit"
  get "/auth/fitbit/callback", to: "sessions#create"
  get "signout", to: "sessions#destroy"
  get "/results", to: "site#results"
  get "/stats", to: "site#stats"
  get "/trips", to: "site#trips"
end
