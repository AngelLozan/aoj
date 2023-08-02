Rails.application.routes.draw do
  resources :paintings
  devise_for :users, controllers: {
    sessions: 'custom_devise/sessions'
  }
  root to: "pages#home"

end
