Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  resources :repos, param: :name, only: [:show] do
    resources :tags, param: :name, only: [:index] do
      get :latest, on: :collection
    end
    resources :branches, param: :name, constraints: {name: /.*/}, only: [:index] do
      resources :builds, only: [:index]
    end

    resources :deploys, only: [:new, :create, :show] do
      get :select_target, on: :collection
      post :complete, on: :member
      post :cancel, on: :member
      post :rollback, on: :member
    end
  end

  resources :targets, param: :name, only: [:show] do
    resources :locks, only: [:index]
    post :lock, on: :member
    post :unlock, on: :member
  end

  resources :servers

  namespace :api, defaults: {format: "json"} do
    # TODO: This is the new format for the api that we should switch the ones below to.
    # We'll have to find a good time to do that like when we switch to pull_agent.
    resources :targets, param: :name, only: [] do
      resources :deploys, only: [:index] do
        post :latest, on: :collection
      end
    end

    resources :deploy, only: [] do
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
