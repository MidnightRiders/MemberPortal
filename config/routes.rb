MLSPickEm::Application.routes.draw do

  devise_for :users
  resources :users, only: [ :index, :show ] do
    collection { post :import }
  end
  get '/home', to: 'users#home'

  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  root to: 'static_pages#home'
end
