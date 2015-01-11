MidnightRiders::Application.routes.draw do

  get 'stylesheets/club', constraints: { format: :css }
  resources :players

  resources :mot_ms, path: 'motm', only: [ :index ]

  resources :matches do
    collection { post :import }
    resources :mot_ms, path: 'motm', except: [ :index, :show ]
    resources :rev_guesses, path: 'revguess', except: [ :index, :show ]
    resources :pick_ems, path: 'pickem', except: [ :new, :edit, :show, :create, :update ] do
      collection { post :vote }
    end
  end

  resources :clubs

  match 'memberships/webhooks', to: 'memberships#webhooks', via: :all
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users do
    collection do
      post :import
    end
    resources :memberships do
      resources :relatives, type: 'Relative'
    end
    resources :individuals, controller: 'memberships', type: 'Individual'
    resources :families, controller: 'memberships', type: 'Family'
  end

  match 'users/:user_id/memberships/:id/cancel', to: 'memberships#cancel', as: 'cancel_user_membership', via: [ :put, :patch ]

  get 'home', to: 'users#home', as: :user_home

  get 'standings', to: 'static_pages#standings'
  get 'transactions', to: 'static_pages#transactions'
  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  root to: 'static_pages#home'
end