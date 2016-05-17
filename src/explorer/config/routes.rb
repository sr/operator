Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/auth/unauthorized", to: "sessions#unauthorized"

  get "/accounts", to: "accounts#index"
  get "/queries/new", to: "queries#new"
  get "/queries/:id", to: "queries#show"
  post "/queries", to: "queries#create"

  root "welcome#index"
end
