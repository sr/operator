Rails.application.routes.draw do
  resources :sessions, only: [:new] do
    delete :destroy, on: :collection
  end
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  resources :accounts, only: :index do
    resources :queries, except: [:destroy, :edit]
  end
  resource :global, only: [] do
    resources :queries, except: [:destroy, :edit]
  end
  resources :access_logs, only: :index

  root 'welcome#index'
end
