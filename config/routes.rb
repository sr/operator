Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  post "/auth/:provider/callback", to: "sessions#create"

  namespace :api, defaults: {format: "json"} do
    # TODO: In an ideal world, deploy should be deploys (plural). Do we need to
    # keep the API routes stable for any reason?
    resources :deploy, only: [] do
      post :complete, on: :member
      post :completed_server, on: :member
    end

    # TODO: These path components are a bit out of order, IMO. Can we change
    # these around to be more conventional? -@alindeman
    get "lock/status" => "lock#status"
    get "status/target/:target_name" => "target#status"
    get "status/deploy/:id" => "deploy#status"
    post "lock/target/:target_name" => "target#lock"
    post "unlock/target/:target_name" => "target#unlock"
    post "deploy/target/:target_name" => "target#deploy"
  end

  get "home/index"
  root to: "home#index"
end
