Rails.application.routes.draw do
  devise_for :users

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resource :dashboard, only: :show, controller: "dashboard"
  resources :accounts, only: %i[ index new create edit update ] do
    resource :archive, only: %i[ create destroy ], module: :accounts
  end

  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  root "pages#home"
end
