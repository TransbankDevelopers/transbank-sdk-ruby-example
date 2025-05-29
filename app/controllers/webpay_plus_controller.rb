class WebpayPlusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:commit, :refund]

  PRODUCT = 'Webpay Plus'.freeze

  before_action :set_transbank_transaction

  def create
    begin
      create_tx = {
        buy_order: "O-#{SecureRandom.random_number(1..10000)}",
        session_id: "S-#{SecureRandom.random_number(1..10000)}",
        return_url: webpay_plus_commit_url,
        amount: SecureRandom.random_number(1000..2000)
      }

      @resp = @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:amount], create_tx[:return_url])
      @request_data = create_tx 
      @respond_data = @resp 

   
    rescue StandardError => e
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render 'shared/error_page', locals: { error: e.message }
    end
  end

  def commit
    begin
      if params.key?("TBK_TOKEN") && params.key?("token_ws")
        @view_template = 'error/webpay/form_error'
        @request_data = params
        @product_name = PRODUCT
      elsif params.key?("TBK_TOKEN")
        # Pago abortado
        @view_template = 'error/webpay/aborted'
        @request_data = params
        @resp = @transaction.status(params["TBK_TOKEN"])
      elsif params.key?("token_ws")
        # Flujo normal: 'webpay.commit'
        @resp = @transaction.commit(params["token_ws"])
        @view_template = 'webpay_plus/commit' 
        @token = params["token_ws"]
      else
        # Timeout o un caso no manejado
        @view_template = 'error/webpay/timeout'
        @request_data = params
        @product_name = PRODUCT
      end

  
      render @view_template
    
    rescue StandardError => e
      flash[:alert] = "Ocurrió un error inesperado en commit: #{e.message}"
      render 'shared/error_page', locals: { error: e.message }
    end
  end

  def refund
    begin
      req_params = params.except(:_token) 

      token_to_refund = req_params[:token]
      amount_to_refund = req_params[:amount].to_i

      @resp = @transaction.refund(token_to_refund, amount_to_refund)
      @token = token_to_refund

    
    rescue StandardError => e
      flash[:alert] = "Ocurrió un error inesperado en refund: #{e.message}"
      render 'shared/error_page', locals: { error: e.message }
    end
  end

  def status
    begin
      token = params[:token]
      @resp = @transaction.status(token)
      @request_data = params 

  
    rescue StandardError => e
      flash[:alert] = "Ocurrió un error inesperado en status: #{e.message}"
      @resp = nil
      render 'shared/error_page', locals: { error: e.message }
    end
  end

  def show_operations

  end


  private

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::WebpayPlus::Transaction.new(options)

  end
end
