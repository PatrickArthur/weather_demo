Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "forcasts#new"

  get '/forcasts', to: 'forcasts#display'
  post '/forcasts', to: 'forcasts#search'
  get '/forcasts/new', to: 'patients#new'
end
