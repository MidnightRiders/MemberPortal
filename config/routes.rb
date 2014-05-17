MidnightRiders::Application.routes.draw do

  get 'stylesheets/club'
  resources :players

  resources :mot_ms, path: 'motm', only: [ :index ]

  resources :matches do
    collection { get :import }
    resources :mot_ms, path: 'motm', except: [ :index, :show ]
    resources :rev_guesses, path: 'revguess', except: [ :index, :show ]
    resources :pick_ems, path: 'pickem', except: [ :new, :edit, :show, :create, :update ] do
      collection { post :vote }
    end
  end

  resources :clubs

  match 'users/sign_up', to: 'static_pages#home', via: :all
  devise_for :users
  resources :users do
    collection do
      post :import
    end
    resources :memberships
  end

  get 'home', to: 'users#home', as: :user_home

  get 'games', to: 'static_pages#games'
  get 'standings', to: 'static_pages#standings'

  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  root to: 'static_pages#home'
end
