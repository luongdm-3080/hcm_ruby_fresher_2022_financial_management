Rails.application.routes.draw do
  devise_for :users, skip: %i(registrations sessions confirmations passwords), controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  scope "(:locale)", locale: /en|ja|vi/ do
    devise_for :users, skip: :omniauth_callbacks
    root "transactions#index"
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
      resources :users do
        member do
          patch "restore"
          delete "really_destroy"
        end
        get "restores", on: :collection
      end
    end
  end
end
