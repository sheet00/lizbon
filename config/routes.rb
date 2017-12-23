Rails.application.routes.draw do
  resources :capitals
  resources :wallet_histories
  resources :trade_settings

  resources :active_orders do
    member do
      get :cancel
    end

    collection do
      get :sync_zaif
    end
  end

  resources :currency_pairs
  resources :currency_pairs
  resources :targets
  resources :bots
  resources :trades
  resources :trade_histories
  resources :currency_histories

  resources :wallets do
    member do
      get :add
      patch :add_money
    end
  end


  get 'exec/index'
  get 'home/index'
  get 'reports/pl'
  get 'reports/average'

  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
