Rails.application.routes.draw do
  resources :blocks, only: [:index, :new, :create]
  root "blocks#index"
end