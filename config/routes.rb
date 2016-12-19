MidnightRiders::Application.routes.draw do

  get 'stylesheets/club', constraints: { format: :css }
  resources :players

  resources :mot_ms, path: 'motm', only: [ :index ]

  resources :matches do
    collection do
      post :import
      post :bulk_update
      get :auto_update
    end
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
    resources :memberships, controller: 'memberships', type: 'Individual'
    resources :memberships, controller: 'memberships', type: 'Family' do
      resources :relatives, type: 'Relative', only: [ :new, :create, :destroy ] do
        member do
          post :accept_invitation, as: :accept_invitation_for
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :sessions, only: %w(create destroy)
    end
  end

  get 'downloads/:filename', to: 'downloads#show', as: :download

  match 'users/:user_id/memberships/:id/cancel', to: 'memberships#cancel', as: :cancel_user_membership, via: [ :put, :patch ]

  get 'home', to: 'users#home', as: :user_home

  get 'standings', to: 'static_pages#standings'
  get 'transactions', to: 'static_pages#transactions'
  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  root to: 'static_pages#home'
end
