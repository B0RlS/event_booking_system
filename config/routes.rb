Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users

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

