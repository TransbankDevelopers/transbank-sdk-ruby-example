Rails.application.routes.draw do
  get "product_index/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: 'product_index#index'

  get '/oneclick-mall', to: 'home#oneclick_mall', as: :oneclick_mall
  get '/transaccion-completa', to: 'home#transaccion_completa', as: :transaccion_completa
  get '/patpass-comercio', to: 'home#patpass_comercio', as: :patpass_comercio

  # --- API Reference ---
  get '/api-reference/webpay-plus', to: 'webpay_plus#show_operations', as: :webpay_plus_api_operations
  get '/api-reference/webpay-mall', to: 'webpay_plus_mall#show_operations', as: :webpay_mall_api_operations
  get '/api-reference/webpay-plus-diferido', to: 'webpay_plus_deferred#show_operations', as: :webpay_deferred_api_operations
  get '/api-reference/webpay-mall-diferido', to: 'webpay_plus_mall_deferred#show_operations', as: :webpay_mall_deferred_api_operations

  # --- Webpay Plus ---
  # Controladores: WebpayPlusController
  get 'webpay-plus/create', to: 'webpay_plus#create', as: :webpay_plus_create
  match 'webpay-plus/commit', to: 'webpay_plus#commit', via: [:get, :post], as: :webpay_plus_commit
  get 'webpay-plus/refund', to: 'webpay_plus#refund', as: :webpay_plus_refund
  get 'webpay-plus/status', to: 'webpay_plus#status', as: :webpay_plus_status

  # --- Webpay Plus Mall ---
  # Controladores: WebpayPlusMallController
  get 'webpay-mall/create', to: 'webpay_plus_mall#create', as: :webpay_mall_create
  get 'webpay-mall/commit', to: 'webpay_plus_mall#commit', as: :webpay_mall_commit
  get 'webpay-mall/refund', to: 'webpay_plus_mall#refund', as: :webpay_mall_refund
  get 'webpay-mall/status', to: 'webpay_plus_mall#status', as: :webpay_mall_status

  # --- Webpay Plus Diferido ---
  # Controladores: WebpayPlusDeferredController
  get 'webpay-plus-diferido/create', to: 'webpay_plus_deferred#create', as: :webpay_deferred_create
  get 'webpay-plus-diferido/commit', to: 'webpay_plus_deferred#commit', as: :webpay_deferred_commit
  get 'webpay-plus-diferido/capture', to: 'webpay_plus_deferred#capture', as: :webpay_deferred_capture
  get 'webpay-plus-diferido/refund', to: 'webpay_plus_deferred#refund', as: :webpay_deferred_refund
  get 'webpay-plus-diferido/status', to: 'webpay_plus_deferred#status', as: :webpay_deferred_status

  # --- Webpay Plus Mall Diferido ---
  # Controladores: WebpayPlusMallDeferredController
  get 'webpay-mall-diferido/create', to: 'webpay_plus_mall_deferred#create', as: :webpay_mall_deferred_create
  get 'webpay-mall-diferido/commit', to: 'webpay_plus_mall_deferred#commit', as: :webpay_mall_deferred_commit
  get 'webpay-mall-diferido/capture', to: 'webpay_plus_mall_deferred#capture', as: :webpay_mall_deferred_capture
  get 'webpay-mall-diferido/refund', to: 'webpay_plus_mall_deferred#refund', as: :webpay_mall_deferred_refund
  get 'webpay-mall-diferido/status', to: 'webpay_plus_mall_deferred#status', as: :webpay_mall_deferred_status

  # --- Oneclick Mall ---
  # Controladores: OneclickMallController
  get 'oneclick-mall/start', to: 'oneclick_mall#start_inscription', as: :oneclick_mall_start # Acción renombrada a snake_case
  get 'oneclick-mall/finish', to: 'oneclick_mall#finish_inscription', as: :oneclick_mall_finish
  post 'oneclick-mall/authorize', to: 'oneclick_mall#authorize_mall', as: :oneclick_mall_authorize
  get 'oneclick-mall/delete', to: 'oneclick_mall#delete_inscription', as: :oneclick_mall_delete
  get 'oneclick-mall/refund', to: 'oneclick_mall#refund', as: :oneclick_mall_refund
  get 'oneclick-mall/status', to: 'oneclick_mall#status', as: :oneclick_mall_status

  # --- Oneclick Mall Diferido ---
  # Controladores: OneclickMallDeferredController
  get 'oneclick-mall-diferido/start', to: 'oneclick_mall_deferred#start_inscription', as: :oneclick_mall_deferred_start
  get 'oneclick-mall-diferido/finish', to: 'oneclick_mall_deferred#finish_inscription', as: :oneclick_mall_deferred_finish
  post 'oneclick-mall-diferido/authorize', to: 'oneclick_mall_deferred#authorize_mall', as: :oneclick_mall_deferred_authorize
  get 'oneclick-mall-diferido/delete', to: 'oneclick_mall_deferred#delete_inscription', as: :oneclick_mall_deferred_delete
  get 'oneclick-mall-diferido/status', to: 'oneclick_mall_deferred#status', as: :oneclick_mall_deferred_status
  get 'oneclick-mall-diferido/refund', to: 'oneclick_mall_deferred#refund', as: :oneclick_mall_deferred_refund
  get 'oneclick-mall-diferido/capture', to: 'oneclick_mall_deferred#capture', as: :oneclick_mall_deferred_capture
end
