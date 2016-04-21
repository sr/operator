Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  get "/accounts", to: "accounts#index"
  get "/queries", to: "queries#new"
  post "/queries(.:format)", to: "queries#create"

  root "welcome#index"
end
