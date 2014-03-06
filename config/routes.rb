MidnightRiders::Application.routes.draw do

  resources :players

  resources :matches

  resources :clubs

  devise_for :users
  resources :users do
    collection { post :import }
  end
  get '/home', to: 'users#home'

  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  root to: 'static_pages#home'
end
