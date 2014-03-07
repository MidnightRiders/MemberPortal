MidnightRiders::Application.routes.draw do

  get 'stylesheets/club'
  resources :players

  resources :mot_ms, path: 'motm', only: [ :index ]

  resources :matches do
    collection { get :import }
    resources :mot_ms, path: 'motm', except: [ :show ]
    resources :rev_guesses, path: 'revguess', except: [ :show ]
    resources :pick_ems, path: 'pickem', except: [ :new, :edit, :show, :create, :update ] do
      collection { post :vote }
    end
  end

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
