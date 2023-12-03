Rails.application.routes.draw do
  get 'prints/index', to: 'prints#index', as: 'prints'
  get 'prints/show', to: 'prints#show', as: 'print'
  post '/add_to_cart_print/:id', to: "prints#add_to_cart", as: 'add_to_cart_print'
  delete '/remove_from_cart_print/:id', to: "prints#remove_from_cart", as: 'remove_from_cart_print'
  # resources :nfts, only: [ :index ] do
  #   collection do
  #     post 'set_image_urls'
  #     # get 'nfts'
  #   end
  # end
  post '/set_image_urls', to: 'nfts#set_image_urls', as: 'set_image_urls'
  get '/nfts', to: 'nfts#nfts', as: 'nfts'
  get '/endpoint', to: 'nfts#endpoint', as: 'endpoint'


  resources :contacts, only: [:new, :create]

  resources :paintings
  get '/admin', to: 'paintings#admin', as: 'admin'
  devise_for :users, controllers: {
    sessions: 'custom_devise/sessions'
  }
  root to: "pages#home"
  get '/cv', to: "pages#cv", as: 'cv'
  get '/about', to: "pages#about", as: 'about'
  get '/comissions', to: "pages#comissions", as: 'comissions'
  get '/privacy', to: "pages#privacy", as: 'privacy'
  get '/terms', to: "pages#terms", as: 'terms'
  get '/photography', to: "pages#photography", as: 'photography'


  post '/add_to_cart/:id', to: "paintings#add_to_cart", as: 'add_to_cart'
  delete '/remove_from_cart/:id', to: "paintings#remove_from_cart", as: 'remove_from_cart'


  get '/orders/new', to: "orders#new", as: 'new_order'
  post '/orders', to: "orders#create", as: 'create_order'
  get '/orders/:id', to: "orders#show", as: 'order'
  get '/orders', to: "orders#index", as: 'orders'
  get '/orders/:id/edit', to: "orders#edit", as: 'edit_order'
  patch '/orders/:id', to: "orders#update", as: 'update_order'
  delete '/orders/:id', to: "orders#destroy", as: 'destroy_order'

  get '/wallet', to: "orders#wallet", as: 'wallet'
  get '/btcwallet', to: "orders#btcwallet", as: 'btcwallet'
end
