Rails.application.routes.draw do
  get 'sessions/new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  post 'users/:id',	to: 'users#update'
  get 'users/download_file', to: 'users#download_file'
  get 'users/videos', to: 'users#videos'

  get 'home/index'

  resources :users
  
  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
