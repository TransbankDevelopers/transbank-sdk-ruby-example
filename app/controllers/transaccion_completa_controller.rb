require 'logger'

class TransaccionCompletaController < ApplicationController

  PRODUCT = "Transacción completa".freeze
  ERROR_PAGE = "shared/error_page".freeze
  logger = Logger.new(STDOUT)

  before_action :set_transbank_transaction

  def index
    render :index
  end

  def create
    req = params.permit(:number, :expiry, :cvc)
    
    begin
      card_number_clean = req[:number].to_s.gsub(/\s+/, '')
      
      month, year = req[:expiry].to_s.split('/')
      card_expiry_formatted = "#{year}/#{month}" 
      
      create_tx = {
        buy_order: "O-#{rand(1..10000)}",
        session_id: "S-#{rand(1..10000)}",
        amount: rand(1000..2000)
      }
      resp = @tx.create(
        create_tx[:buy_order],
        create_tx[:session_id],
        create_tx[:amount],
        req[:cvc],
        card_number_clean,
        card_expiry_formatted
      )
      session[:transaccion_completa_amount] = create_tx[:amount]
      
      @request_data = create_tx
      @response_data = resp
      render 'create'

    rescue StandardError => e
      logger.error(e)
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def installments
    req = params.permit(:token, :installments_number)
    
    begin
      resp = @tx.installments(req[:token], req[:installments_number].to_i)

      @request_data = req
      @response_data = resp
      render 'installments'

    rescue StandardError => e
      logger.error("Error en Transacción Completa - Installments: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def commit
    req = params.permit(:token, :idQueryInstallments)
    deferred_period_index = nil
    grace_period = false
    begin
      id_query_installments = req[:idQueryInstallments].presence 

      resp = @tx.commit(
        req[:token],
        id_query_installments,
        deferred_period_index,
        grace_period
      )

      @amount = session[:transaccion_completa_amount]
      session.delete(:transaccion_completa_amount) 
      
      @request_data = req
      @response_data = resp

      render 'commit'

    rescue StandardError => e
      logger.error("Error en Transacción Completa - Commit: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def status
    req = params.permit(:token)
    
    begin
      resp = @tx.status(req[:token])

      @request_data = req
      @response_data = resp
      render 'status'

    rescue StandardError => e
      logger.error("Error en Transacción Completa - Status: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refund
    req = params.permit(:token, :amount)
    
    begin
      resp = @tx.refund(req[:token], req[:amount].to_i)

      @request_data = req
      @response_data = resp
      render 'refund'

    rescue StandardError => e
      logger.error("Error en Transacción Completa - Refund: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

   private

  def create_transaction
    create_tx = {
      buy_order: "O-#{SecureRandom.random_number(1..10000)}",
      session_id: "S-#{SecureRandom.random_number(1..10000)}",
      return_url: webpay_plus_commit_url,
      amount: SecureRandom.random_number(1000..2000)
    }

    @tx.create(create_tx[:buy_order], create_tx[:session_id], create_tx[:amount], create_tx[:return_url])
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::TRANSACCION_COMPLETA
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::TransaccionCompleta::Transaction.new(options)
  end
end

