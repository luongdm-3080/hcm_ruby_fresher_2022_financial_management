Rails.application.routes.draw do
  scope "(:locale)", locale: /en|ja|vi/ do
    root "static_pages#home"
    get "/help", to: "static_pages#help"
    get "/home", to: "static_pages#home"
    get "/about", to: "static_pages#about"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users
    resources :wallets, except: %i(edit) do
      resources :transactions, only: %i(index show) do
        get "/chart", to: "transactions#chart", on: :collection
      end
    end
    resources :categories, except: %i(new show edit)
    resources :transactions, only: %i(create destroy update)
    namespace :admin do
      root "users#index"
      resources :users, only: :index
    end
  end
end
