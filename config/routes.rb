Rails.application.routes.draw do
  devise_for :organizations
  root to: 'distributions#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :organizations, only: [:show]
  resources :distributions
end
