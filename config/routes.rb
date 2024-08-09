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
  resources :api_tokens, only: %i[ index create destroy ], controller: "users/api_tokens"
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
  resources :categories do
    resource :merge, only: :create, module: :categories
  end
  resources :rules, except: %i[ show new ]
  resources :tags, only: %i[ index update destroy ]
  resource :rule_application, only: :create, controller: "rules/applications"
  resources :budgets, except: :show
  resources :goals, except: :show
  resources :exchange_rates, only: %i[ index create destroy ]
  resource :reports, only: :show
  get "reports/year/(:year)", to: "reports/years#show", as: :reports_year
  resource :budget_copy, only: :create, controller: "budgets/copies"
  resources :accounts do
    resource :archive, only: %i[ create destroy ], module: :accounts
    resource :reconciliation, only: %i[ new create ], module: :accounts
    resource :position, only: :update, module: :accounts
  end

  namespace :api do
    namespace :v1 do
      resource :me, only: :show, controller: "me"
      resources :accounts, only: :index
      resources :categories, only: :index
      resources :transactions, only: %i[ index show create update destroy ]
      resources :deletions, only: :index
    end
  end

  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  root "pages#home"
end
