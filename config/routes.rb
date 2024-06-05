Rails.application.routes.draw do
  devise_for :users

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount GoodJob::Engine, at: "/good_job"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resource :dashboard, only: :show, controller: "dashboard"
  resource :data_export, only: :show, controller: "users/data_exports"
  resources :transactions, except: :show do
    get :export, on: :collection, defaults: { format: :csv }
    resources :receipts, only: :destroy, module: :transactions
  end
  resource :quick_add, only: :create, controller: "transactions/quick_adds"
  resource :transactions_bulk, only: %i[ update destroy ], controller: "transactions/bulks"
  resources :transfers, except: %i[ index show ]
  resources :recurring_transactions, except: :show, path: "recurring"
  resources :imports, only: %i[ index new create edit update show ] do
    post :run, on: :member
    post :undo, on: :member
  end
  resources :categories
  resources :rules, except: %i[ show new ]
  resource :rule_application, only: :create, controller: "rules/applications"
  resources :budgets, except: :show
  resources :goals, except: :show
  resource :reports, only: :show
  resource :budget_copy, only: :create, controller: "budgets/copies"
  resources :accounts do
    resource :archive, only: %i[ create destroy ], module: :accounts
    resource :reconciliation, only: %i[ new create ], module: :accounts
  end

  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  root "pages#home"
end
