require 'logger'

class WebpayPlusMallController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :commit, :refund ]

  PRODUCT = "Webpay Plus".freeze
  ERROR_PAGE = "shared/error_page".freeze
  logger = Logger.new(STDOUT)

  before_action :set_transbank_transaction

  def create
    begin
      @details =[
      {
        "amount"=>"1000",
        "commerce_code"=>::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_MALL_CHILD1,
        "buy_order"=>"childBuyOrder1_#{rand(1000)}"
      },
      {
        "amount"=>"2000",
        "commerce_code"=>::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_MALL_CHILD2,
        "buy_order"=>"childBuyOrder2_#{rand(1000)}"
      }
      ]
      create_tx = {
        buy_order: "O-#{SecureRandom.random_number(1..10000)}",
        session_id: "S-#{SecureRandom.random_number(1..10000)}",
        return_url: webpay_mall_commit_url,
        amount: SecureRandom.random_number(1000..2000),
        details: @details
      }
      @resp = @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:return_url], @details)
      @request_data = create_tx
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def commit
    begin
      @request_data = params
      @product_name = PRODUCT
      @create_url = webpay_mall_create_url
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
        @view_template = "webpay_plus_mall/commit"
        @token = params["token_ws"]
        @returnUrl = webpay_mall_commit_url
        @respond_data = @resp.with_indifferent_access
      else
        # Timeout o un caso no manejado
        @view_template = "error/webpay/timeout"
      end


      render @view_template

    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en commit: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refund
    begin
      req_params = params.except(:_token)

      token_to_refund = req_params[:token]
      commerce_code_to_refund = req_params[:commerce_code]
      buy_order_to_refund = req_params[:buy_order]
      amount_to_refund = req_params[:amount].to_i

      @resp = @tx.refund(token_to_refund, buy_order_to_refund, commerce_code_to_refund, amount_to_refund)

      @token = token_to_refund
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado en refund: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
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
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refresh_respond_data_json
    @respond_data = create_transaction.with_indifferent_access
    render json: @respond_data
  end

  private

  def create_transaction
    @details =[
      {
        "amount"=>"1000",
        "commerce_code"=>::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_MALL_CHILD1,
        "buy_order"=>"childBuyOrder1_#{rand(1000)}"
      },
      {
        "amount"=>"2000",
        "commerce_code"=>::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_MALL_CHILD2,
        "buy_order"=>"childBuyOrder2_#{rand(1000)}"
      }
      ]
      create_tx = {
        buy_order: "O-#{SecureRandom.random_number(1..10000)}",
        session_id: "S-#{SecureRandom.random_number(1..10000)}",
        return_url: webpay_mall_commit_url,
        amount: SecureRandom.random_number(1000..2000),
        details: @details
      }
    @resp = @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:return_url], @details)
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS_MALL
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::WebpayPlus::MallTransaction.new(options)
  end
end
