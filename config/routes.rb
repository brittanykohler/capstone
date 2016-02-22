Rails.application.routes.draw do
  root "site#index"

  get "/auth/fitbit"
  get "/auth/fitbit/callback", to: "sessions#create"
  get "signout", to: "sessions#destroy"

end
