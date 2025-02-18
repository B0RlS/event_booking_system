Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: 'events#index'

  namespace :api do
    namespace :v1 do
      resources :events, only: %i[index show] do
        resources :tickets, only: [:create]
      end

      resources :tickets, only: %i[index show destroy]

      namespace :manager do
        resources :events, except: %i[index show] do
          resources :tickets, only: [:index]
        end
      end
    end
  end
end

