Rails.application.routes.draw do
	resources :wallet_histories
	resources :trade_settings

	resources :active_orders do
		member do
			get :cancel
		end
	end

	resources :currency_pairs
	resources :currency_pairs
	resources :targets
	resources :bots
	resources :trade_histories
	resources :trades
	resources :currency_histories
	resources :wallets do
		member do
			get :add
			patch :add_money
		end
	end

	root to: 'home#index'

	get 'exec/index'
	get 'home/index'

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
