MidnightRiders::Application.routes.draw do
  get 'stylesheets/club', constraints: { format: :css }
  resources :players, except: %i(show destroy)

  get 'motm', to: 'mot_ms#index', as: :mot_ms

  scope 'matches/:match_id', match_id: /\d+/ do
    get '/', to: 'matches#show', as: nil, constraints: ->(req) { req.format == :json }
    get 'motm', to: 'mot_ms#show', as: nil, constraints: ->(req) { req.format == :json }
    get 'motm', to: 'matches#index', as: :mot_m, mot_m: true
    match 'motm', to: 'mot_ms#create', via: %i(put post)
    get 'rev_guess', to: 'rev_guesses#show', as: nil, constraints: ->(req) { req.format == :json }
    get 'rev_guess', to: 'matches#index', as: :rev_guess, rev_guess: true
    match 'rev_guess', to: 'rev_guesses#create', via: %i(put post)
    match 'pick_em', to: 'pick_em#create', via: %i(put post), as: :pick
  end

  resources :matches do
    collection do
      post :import
      get :auto_update
    end
  end

  resources :clubs, except: %i(destroy)

  match 'memberships/webhooks', to: 'memberships#webhooks', via: :all
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users do
    collection do
      post :import
    end
    resources :memberships, controller: 'memberships', type: 'Individual', only: %i(index show new create destroy)
    resources :memberships, controller: 'memberships', type: 'Family', only: %i(index show new create destroy) do
      resources :relatives, type: 'Relative', only: %i(new create destroy) do
        member do
          post :accept_invitation, as: :accept_invitation_for
        end
      end
    end
  end

  get 'downloads/:filename', to: 'downloads#show', as: :download

  match 'users/:user_id/memberships/:id/cancel', to: 'memberships#cancel', as: :cancel_user_membership, via: %i(put patch)

  get 'home', to: 'users#home', as: :user_home

  get 'standings', to: 'static_pages#standings'
  get 'transactions', to: 'static_pages#transactions'
  get 'faq', to: 'static_pages#faq'
  get 'contact', to: 'static_pages#contact'

  post 'nominate', to: 'static_pages#nominate'

  root to: 'static_pages#home'
end
