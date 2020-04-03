Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { registrations: 'registrations' }

  #scope '(:locale)', locale: /en/ do
    root to: 'pages#home'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :organizations, only: [:show, :index, :new, :create]
    resources :distributions, except: [:index]

    post '/distributions/:id/accept', to: 'distributions#accept', as: 'accept_distribution'
    post '/distributions/:id/decline', to: 'distributions#decline', as: 'decline_distribution'
    post '/distributions/:id/pause', to: 'distributions#pause', as: 'pause_distribution'
    post '/distributions/:id/unpause', to: 'distributions#unpause', as: 'unpause_distribution'

    get 'search', to: 'distributions#search'
    get '/explore', to: 'distributions#explore'
    get '/covid_19', to: 'distributions#covid_19'

    post '/sms', to: 'messages#receive'

    post '/call', to: 'calls#receive'

    get '/beta', to: 'pages#beta', as: :beta_page

    get '/about', to: 'pages#about', as: :about_page


    resources :users, only: [:show]
  #end

end
