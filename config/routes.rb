Rails.application.routes.draw do
  get "product_index/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker


  root to: "product_index#index"

  # Webpay Plus routes
  namespace :webpay_plus do
    get :create
    get :commit
    get :status
    get :show_refund
    post :refund
  end

  # Webpay Plus Deferred routes
  namespace :webpay_plus_deferred do
    get :create
    get :commit
    get :status
    get :show_capture
    get :show_refund
    post :capture
    post :refund
  end

  # Webpay Plus Mall routes
  namespace :webpay_plus_mall do
    get :create
    get :commit
    get :status
    get :show_refund
    post :refund
  end

  # Webpay Plus Mall Deferred routes
  namespace :webpay_plus_mall_deferred do
    get :create
    post :send_create
    get :commit
    get :status
    get :show_capture
    get :show_refund
    post :capture
    post :refund
  end

  # OneClick Mall routes
  namespace :oneclick_mall do
    get :start
    get :finish
    get :authorize
    get :status
    get :show_refund
    post :refund
    delete :delete
  end

  # OneClick Mall Deferred routes
  namespace :oneclick_mall_deferred do
    get :start
    get :finish
    get :authorize
    get :status
    get :show_capture
    get :show_refund
    post :capture
    post :refund
    delete :delete
  end

  # Transacción Completa routes
  namespace :transaccion_completa do
    get :form
    get :show_create
    get :show_installments
    get :show_commit
    get :status
    get :show_refund
    post :create
    post :installments
    post :commit
    post :refund
  end

  # Transacción Completa Deferred routes
  namespace :transaccion_completa_deferred do
    get :form
    get :show_create
    get :show_installments
    get :show_commit
    get :status
    get :show_capture
    get :show_refund
    post :create
    post :installments
    post :commit
    post :capture
    post :refund
  end

  # Transacción Completa Mall routes
  namespace :transaccion_completa_mall do
    get :form
    get :show_create
    get :show_installments
    get :show_commit
    get :status
    get :show_refund
    post :create
    post :installments
    post :commit
    post :refund
  end

  # Transacción Completa Mall Deferred routes
  namespace :transaccion_completa_mall_deferred do
    get :form
    get :show_create
    get :show_installments
    get :show_commit
    get :status
    get :show_capture
    get :show_refund
    post :create
    post :installments
    post :commit
    post :capture
    post :refund
  end

  # Patpass Comercio routes
  namespace :patpass_comercio do
    get :start
    post :commit
    post :show_commit
    post :voucher_return
    post :show_voucher_return
  end
end
