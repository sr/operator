Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  resources :repos, param: :name, only: [:show] do
    resources :tags, param: :name, only: [:index] do
      get :latest, on: :collection
    end
    resources :branches, param: :name, only: [:index]
    resources :commits, param: :sha, only: [:index]

    resources :deploys, only: [:new, :create] do
      get :select_target, on: :collection
    end
  end

  namespace :api, defaults: {format: "json"} do
    # TODO: In an ideal world, deploy should be deploys (plural). What
    # dependencies does the API have that would break if we changed things to be
    # more conventional? -@alindeman
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
