require 'logger'

class WebpayPlusDeferredController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :commit, :refund ]

  PRODUCT = "Webpay Plus Diferido".freeze
  logger = Logger.new(STDOUT)

  before_action :set_transbank_transaction

  def create
    begin
      create_tx = {
        buy_order: "O-#{SecureRandom.random_number(1..10000)}",
        session_id: "S-#{SecureRandom.random_number(1..10000)}",
        return_url: webpay_deferred_commit_url,
        amount: SecureRandom.random_number(1000..2000)
      }
      @resp = @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:amount], create_tx[:return_url])
      @request_data = create_tx
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def commit
    begin
      @request_data = params
      @product_name = PRODUCT
      @create_url = webpay_deferred_create_url
      if params.key?("TBK_TOKEN") && params.key?("token_ws")
        @view_template = "error/webpay/form_error"
      elsif params.key?("TBK_TOKEN")
        # Pago abortado
        @view_template = "error/webpay/aborted"
        @resp = @tx.status(params["TBK_TOKEN"])
        @respond_data = @resp.with_indifferent_access
      elsif params.key?("token_ws")
        # Flujo normal: 'webpay.commit'
        @resp = @tx.commit(params["token_ws"])
        @view_template = "webpay_plus_deferred/commit"
        @token = params["token_ws"]
        @returnUrl = webpay_deferred_commit_url
        @respond_data = @resp.with_indifferent_access
      else
        # Timeout o un caso no manejado
        @view_template = "error/webpay/timeout"
      end

      render @view_template

    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en commit: #{e.message}"
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def refund
    begin
      req_params = params.except(:_token)

      token_to_refund = req_params[:token]
      amount_to_refund = req_params[:amount].to_i

      @resp = @tx.refund(token_to_refund, amount_to_refund)
      @token = token_to_refund
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en refund: #{e.message}"
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def status
    begin
      token = params[:token]
      @resp = @tx.status(token)
      @request_data = params
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en status: #{e.message}"
      @resp = nil
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def capture
    begin
      @req = params.as_json
      @token = params[:token]
      @buy_order = params[:buy_order]
      @authorization_code = params[:authorization_code]
      @amount = params[:amount]
      @resp = @tx.capture(@token, @buy_order, @authorization_code, @amount)  
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en capture: #{e.message}"
      @resp = nil
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def refresh_respond_data_json
    @respond_data = crear_transaccion.with_indifferent_access
    render json: @respond_data
  end
  
  private

  def crear_transaccion
   create_tx = {
      buy_order: "O-#{SecureRandom.random_number(1..10000)}",
      session_id: "S-#{SecureRandom.random_number(1..10000)}",
      return_url: webpay_deferred_commit_url,
      amount: SecureRandom.random_number(1000..2000)
    }
    @resp = @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:amount], create_tx[:return_url])
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_DEFERRED
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::WebpayPlus::Transaction.new(options)
  end
end
