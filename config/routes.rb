Rails.application.routes.draw do

  get "product_index/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get 'webpay-plus/refresh_respond_data_json', to: 'webpay_plus#refresh_respond_data_json', as: :refresh_webpay_plus_json
  get '"webpay-mall/refresh_respond_data_json', to: 'webpay_plus_mall#refresh_respond_data_json', as: :refresh_webpay_mall_json
  get 'webpay-plus-diferido/refresh_respond_data_json', to: 'webpay_plus_deferred#refresh_respond_data_json', as: :refresh_webpay_plus_deferred_json
  get 'webpay-mall-diferido/refresh_respond_data_json', to: 'webpay_plus_mall_deferred#refresh_respond_data_json', as: :refresh_webpay_mall_deferred_json
  root to: "product_index#index"

  get "/oneclick-mall", to: "home#oneclick_mall", as: :oneclick_mall
  get "/promotions-oneclick-mall", to: "promotions_oneclick_mall#start", as: :promotions_oneclick_mall_start
  get "/patpass-comercio", to: "patpass_comercio#start", as: :patpass_comercio
  match "/patpass-comercio/commit", to: "patpass_comercio#commit", via: [ :get, :post ], as: :patpass_comercio_commit
  match "/patpass-comercio/voucher", to: "patpass_comercio#voucher", via: [ :get, :post ], as: :patpass_comercio_voucher

  # --- API Reference ---
  get "/api-reference/webpay-plus", to: "webpay_plus#show_operations", as: :webpay_plus_api_operations
  get "/api-reference/webpay-mall", to: "webpay_plus_mall#show_operations", as: :webpay_mall_api_operations
  get "/api-reference/webpay-plus-diferido", to: "webpay_plus_deferred#show_operations", as: :webpay_deferred_api_operations
  get "/api-reference/webpay-mall-diferido", to: "webpay_plus_mall_deferred#show_operations", as: :webpay_mall_deferred_api_operations

  # --- Webpay Plus ---
  # Controladores: WebpayPlusController
  get "webpay-plus/create", to: "webpay_plus#create", as: :webpay_plus_create
  match "webpay-plus/commit", to: "webpay_plus#commit", via: [ :get, :post ], as: :webpay_plus_commit
  get "webpay-plus/refund", to: "webpay_plus#refund", as: :webpay_plus_refund
  get "webpay-plus/status", to: "webpay_plus#status", as: :webpay_plus_status

  # --- Webpay Plus Mall ---
  # Controladores: WebpayPlusMallController
  get "webpay-mall/create", to: "webpay_plus_mall#create", as: :webpay_mall_create
  match "webpay-mall/commit", to: "webpay_plus_mall#commit", via: [ :get, :post ], as: :webpay_mall_commit
  get "webpay-mall/refund", to: "webpay_plus_mall#refund", as: :webpay_mall_refund
  get "webpay-mall/status", to: "webpay_plus_mall#status", as: :webpay_mall_status

  # --- Webpay Plus Diferido ---
  # Controladores: WebpayPlusDeferredController
  get "webpay-plus-diferido/create", to: "webpay_plus_deferred#create", as: :webpay_deferred_create
  match "webpay-plus-diferido/commit", to: "webpay_plus_deferred#commit", via: [ :get, :post ], as: :webpay_deferred_commit
  get "webpay-plus-diferido/capture", to: "webpay_plus_deferred#capture", as: :webpay_deferred_capture
  get "webpay-plus-diferido/refund", to: "webpay_plus_deferred#refund", as: :webpay_deferred_refund
  get "webpay-plus-diferido/status", to: "webpay_plus_deferred#status", as: :webpay_deferred_status

  # --- Webpay Plus Mall Diferido ---
  # Controladores: WebpayPlusMallDeferredController
  get "webpay-mall-diferido/create", to: "webpay_plus_mall_deferred#create", as: :webpay_mall_deferred_create
  match "webpay-mall-diferido/commit", to: "webpay_plus_mall_deferred#commit", via: [ :get, :post ], as: :webpay_mall_deferred_commit
  get "webpay-mall-diferido/capture", to: "webpay_plus_mall_deferred#capture", as: :webpay_mall_deferred_capture
  get "webpay-mall-diferido/refund", to: "webpay_plus_mall_deferred#refund", as: :webpay_mall_deferred_refund
  get "webpay-mall-diferido/status", to: "webpay_plus_mall_deferred#status", as: :webpay_mall_deferred_status

  # --- Oneclick Mall ---
  # Controladores: OneclickMallController
  get "oneclick-mall/start", to: "oneclick_mall#start", as: :oneclick_mall_start 
  get "oneclick-mall/finish", to: "oneclick_mall#finish", as: :oneclick_mall_finish
  get "oneclick-mall/authorize", to: "oneclick_mall#authorize", as: :oneclick_mall_authorize
  get "oneclick-mall/delete", to: "oneclick_mall#delete", as: :oneclick_mall_delete
  get "oneclick-mall/refund", to: "oneclick_mall#refund", as: :oneclick_mall_refund
  get "oneclick-mall/status", to: "oneclick_mall#status", as: :oneclick_mall_status

  # --- Oneclick Mall Promociones ---
  get "promotions-oneclick-mall/finish", to: "promotions_oneclick_mall#finish", as: :promotions_oneclick_mall_finish
  get "promotions-oneclick-mall/authorize", to: "promotions_oneclick_mall#authorize", as: :promotions_oneclick_mall_authorize
  get "promotions-oneclick-mall/delete", to: "promotions_oneclick_mall#delete", as: :promotions_oneclick_mall_delete
  get "promotions-oneclick-mall/refund", to: "promotions_oneclick_mall#refund", as: :promotions_oneclick_mall_refund
  get "promotions-oneclick-mall/status", to: "promotions_oneclick_mall#status", as: :promotions_oneclick_mall_status
  get "promotions-oneclick-mall/info-bin", to: "promotions_oneclick_mall#info_bin", as: :promotions_oneclick_mall_info_bin

  # --- Oneclick Mall Diferido ---
  # Controladores: OneclickMallDeferredController
  get "oneclick-mall-diferido/start", to: "oneclick_mall_deferred#start", as: :oneclick_mall_deferred_start
  get "oneclick-mall-diferido/finish", to: "oneclick_mall_deferred#finish", as: :oneclick_mall_deferred_finish
  get "oneclick-mall-diferido/authorize", to: "oneclick_mall_deferred#authorize", as: :oneclick_mall_deferred_authorize
  get "oneclick-mall-diferido/delete", to: "oneclick_mall_deferred#delete", as: :oneclick_mall_deferred_delete
  get "oneclick-mall-diferido/status", to: "oneclick_mall_deferred#status", as: :oneclick_mall_deferred_status
  get "oneclick-mall-diferido/refund", to: "oneclick_mall_deferred#refund", as: :oneclick_mall_deferred_refund
  get "oneclick-mall-diferido/capture", to: "oneclick_mall_deferred#capture", as: :oneclick_mall_deferred_capture

  # --- TX Completa ---
  # Controladores: TransaccionCompletaController
  get "transaccion-completa", to: "transaccion_completa#index", as: :transaccion_completa_index
  get "transaccion-completa/commit", to: "transaccion_completa#commit", as: :transaccion_completa_commit
  post "transaccion-completa/installments", to: "transaccion_completa#installments", as: :transaccion_completa_installments
  post "transaccion-completa/create", to: "transaccion_completa#create", as: :transaccion_completa_create
  get "transaccion-completa/status", to: "transaccion_completa#status", as: :transaccion_completa_status
  get "transaccion-completa/refund", to: "transaccion_completa#refund", as: :transaccion_completa_refund
  
  # --- TX Completa Mall ---
  # Controladores: TransaccionCompletaMallController
  get "transaccion-completa-mall", to: "transaccion_completa_mall#index", as: :transaccion_completa_mall_index
  get "transaccion-completa-mall/commit", to: "transaccion_completa_mall#commit", as: :transaccion_completa_mall_commit
  post "transaccion-completa-mall/installments", to: "transaccion_completa_mall#installments", as: :transaccion_completa_mall_installments
  post "transaccion-completa-mall/create", to: "transaccion_completa_mall#create", as: :transaccion_completa_mall_create
  get "transaccion-completa-mall/status", to: "transaccion_completa_mall#status", as: :transaccion_completa_mall_status
  get "transaccion-completa-mall/refund", to: "transaccion_completa_mall#refund", as: :transaccion_completa_mall_refund
  
  # --- TX Completa Mall Diferida ---
  # Controladores: TransaccionCompletaMallDiferidaController
  get "transaccion-completa-mall-diferido", to: "transaccion_completa_mall_diferida#index", as: :transaccion_completa_mall_diferida_index
  get "transaccion-completa-mall-diferido/commit", to: "transaccion_completa_mall_diferida#commit", as: :transaccion_completa_mall_diferida_commit
  post "transaccion-completa-mall-diferido/installments", to: "transaccion_completa_mall_diferida#installments", as: :transaccion_completa_mall_diferida_installments
  post "transaccion-completa-mall-diferido/create", to: "transaccion_completa_mall_diferida#create", as: :transaccion_completa_mall_diferida_create
  get "transaccion-completa-mall-diferido/status", to: "transaccion_completa_mall_diferida#status", as: :transaccion_completa_mall_diferida_status
  get "transaccion-completa-mall-diferido/refund", to: "transaccion_completa_mall_diferida#refund", as: :transaccion_completa_mall_diferida_refund
  get "transaccion-completa-mall-diferido/capture", to: "transaccion_completa_mall_diferida#capture", as: :transaccion_completa_mall_diferida_capture
  
  # --- TX Completa Diferida ---
  # Controladores: TransaccionCompletaDiferidaController
  get "transaccion-completa-diferida", to: "transaccion_completa_diferida#index", as: :transaccion_completa_diferida_index
  get "transaccion-completa-diferida/commit", to: "transaccion_completa_diferida#commit", as: :transaccion_completa_diferida_commit
  post "transaccion-completa-diferida/installments", to: "transaccion_completa_diferida#installments", as: :transaccion_completa_diferida_installments
  post "transaccion-completa-diferida/create", to: "transaccion_completa_diferida#create", as: :transaccion_completa_diferida_create
  get "transaccion-completa-diferida/status", to: "transaccion_completa_diferida#status", as: :transaccion_completa_diferida_status
  get "transaccion-completa-diferida/refund", to: "transaccion_completa_diferida#refund", as: :transaccion_completa_diferida_refund
  get "transaccion-completa-diferida/capture", to: "transaccion_completa_diferida#capture", as: :transaccion_completa_diferida_capture

end
