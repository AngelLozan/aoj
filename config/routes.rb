Rails.application.routes.draw do
  # resources :payments, only: %i[ new create ]
  # get 'payments/new', to: 'payments#new', as: 'new_payment'
  # post 'payments/create', to: 'payments#create', as: 'payments'

  resources :paintings
  get '/admin', to: 'paintings#admin', as: 'admin'
  devise_for :users, controllers: {
    sessions: 'custom_devise/sessions'
  }
  root to: "pages#home"
  get '/cv', to: "pages#cv", as: 'cv'
  get '/about', to: "pages#about", as: 'about'
  get '/photography', to: "pages#photography", as: 'photography'
  post '/add_to_cart/:id', to: "paintings#add_to_cart", as: 'add_to_cart'
  delete '/remove_from_cart/:id', to: "paintings#remove_from_cart", as: 'remove_from_cart'

  get '/orders/new', to: "orders#new", as: 'new_order'
  post '/orders', to: "orders#create", as: 'create_order'
  get '/orders/:id', to: "orders#show", as: 'order'
  get '/orders', to: "orders#index", as: 'orders'
  # Need update and destroy for orders

end
