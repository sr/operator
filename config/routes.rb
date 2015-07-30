Rails.application.routes.draw do
  resources :sessions, only: [:new]
  post "/auth/:provider/callback", to: "sessions#create"

  get "home/index"
  root to: "home#index"
end
