Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/auth/unauthorized", to: "sessions#unauthorized"

  get "/accounts", to: "accounts#index"
  resources :queries, only: [:new, :show, :create]
  get "/_boomtown", to: "welcome#boomtown"
  get "/version", to: "welcome#version"
  root "welcome#index"
end
