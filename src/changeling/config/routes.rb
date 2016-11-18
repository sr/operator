module Constraints
  class GitHubOauthConstraint
    def matches?(request)
      !!request.session[:user_id]
    end
  end
end

Rails.application.routes.draw do
  root "multipasses#index"

  mount Sidekiq::Web => "/sidekiq", constraints: Constraints::GitHubOauthConstraint.new
  get "/auth/:provider/callback", to: "sessions#create"
  post "/signout", to: "sessions#destroy", as: :signout

  post "/events", to: "events#create"
  post "/webhooks", to: "webhooks#create"

  resources :multipasses, only: [:index, :show, :update] do

    member do
      post "review"
      post "sre-approve"
      post "emergency"
      post "reject"
      post "sync"

      delete "reject", to: "multipasses#reopen"
      delete "emergency", to: "multipasses#unset_emergency"
      delete "review", to: "multipasses#remove_review"
      delete "sre-approve", to: "multipasses#remove_sre_approval"
    end
  end

  resource :account, only: [:show, :update]
end
