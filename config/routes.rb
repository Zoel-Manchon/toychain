Rails.application.routes.draw do
  resources :blocks, only: [ :index, :new, :create ] do
    member do
      post :tamper
    end
  end
  root "blocks#index"
end
