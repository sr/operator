Rails.application.routes.draw do
  resources :sessions, only: [:new]
  post "/auth/:provider/callback", to: "sessions#create"

  namespace :api do
    # TODO: In an ideal world, deploy should be deploys (plural). Do we need to
    # keep the API routes stable for any reason?
    resources :deploy do
      post :complete, on: :member
    end
  end

  get "home/index"
  root to: "home#index"
end
