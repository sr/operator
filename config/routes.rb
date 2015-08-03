Rails.application.routes.draw do
  resources :sessions, only: [:new]
  post "/auth/:provider/callback", to: "sessions#create"

  namespace :api, defaults: {format: "json"} do
    # TODO: In an ideal world, deploy should be deploys (plural). Do we need to
    # keep the API routes stable for any reason?
    resources :deploy, only: [] do
      post :complete, on: :member
      post :completed_server, on: :member
    end

    get "lock/status" => "lock#status"
  end

  get "home/index"
  root to: "home#index"
end
