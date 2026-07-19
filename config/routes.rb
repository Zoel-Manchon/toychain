Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token

  resources :blocks, only: [ :index, :new, :create ] do
    member do
      post :tamper
    end

    collection do
      delete :reset
    end
  end

  namespace :api do
    namespace :v1 do
      get "chain", to: "chain#show"
    end
  end

  root "blocks#index"
end
