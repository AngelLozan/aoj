Rails.application.routes.draw do
  resources :paintings
  get '/admin', to: 'paintings#admin', as: 'admin'
  devise_for :users, controllers: {
    sessions: 'custom_devise/sessions'
  }
  root to: "pages#home"
  get '/cv', to: "pages#cv", as: 'cv'
  get '/about', to: "pages#about", as: 'about'
  get '/photography', to: "pages#photography", as: 'photography'

end
