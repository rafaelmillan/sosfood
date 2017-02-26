Rails.application.routes.draw do
  devise_for :users
  devise_for :organizations

  scope '(:locale)', locale: /en/ do
    root to: 'pages#home'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :organizations, only: [:show]
    resources :distributions

    get 'search', to: 'distributions#search'

    post '/sms', to: 'messages#receive'
  end
end
