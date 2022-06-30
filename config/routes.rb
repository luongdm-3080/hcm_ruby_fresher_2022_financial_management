Rails.application.routes.draw do
  scope "(:locale)", locale: /en|ja|vi/ do
    devise_for :users
    root "static_pages#home"
    get "/help", to: "static_pages#help"
    get "/home", to: "static_pages#home"
    get "/about", to: "static_pages#about"
    resources :wallets, except: %i(edit) do
      resources :transactions, only: %i(index show) do
        get "/chart", to: "transactions#chart_analysis", on: :collection
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
