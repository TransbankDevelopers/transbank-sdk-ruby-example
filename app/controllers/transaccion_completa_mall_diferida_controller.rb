class TransaccionCompletaMallDiferidaController < ApplicationController
  include TransaccionCompletaHelper

  PRODUCT = "Transacción completa mall diferida".freeze
  ERROR_PAGE = "shared/error_page".freeze

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

      details = build_mall_details
      create_tx = {
        buy_order: "O-#{rand(1..10000)}",
        session_id: "S-#{rand(1..10000)}",
        details: details
      }

      resp = @tx.create(
        create_tx[:buy_order],
        create_tx[:session_id],
        card_number_clean,
        card_expiry_formatted,
        details,
        req[:cvc]
      )

      session[:transaccion_completa_mall_diferida_details] = details

      @request_data = create_tx
      @response_data = resp
      render 'create'
    rescue StandardError => e
      Rails.logger.error(e)
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def installments
    req = params.permit(:token, :installments_number)

    begin
      Rails.logger.info("TCM diferido installments params: #{params.to_unsafe_h}")
      details = normalize_mall_details_from_session(:transaccion_completa_mall_diferida_details)

      if req[:installments_number].blank?
        return render ERROR_PAGE, locals: { error: "installments_number is required" }
      end

      installments_number = req[:installments_number].to_i
      if installments_number <= 0
        return render ERROR_PAGE, locals: { error: "installments_number must be greater than 0" }
      end

      installment_details = details.map do |detail|
        {
          "commerce_code" => detail[:commerce_code],
          "buy_order" => detail[:buy_order],
          "installments_number" => installments_number
        }
      end

      resp = @tx.installments(req[:token], installment_details)

      @request_data = req
      @response_data = resp
      render 'installments'
    rescue StandardError => e
      Rails.logger.error("Error en Transacción Completa Mall Diferida - Installments: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def commit
    req = params.permit(:token, :idQueryInstallments, :deferredPeriodIndex, :gracePeriod)

    begin
      details = normalize_mall_details_from_session(:transaccion_completa_mall_diferida_details)

      commit_details = details.map do |detail|
        payload = {
          "commerce_code" => detail[:commerce_code],
          "buy_order" => detail[:buy_order]
        }

        if req[:idQueryInstallments].present?
          payload["id_query_installments"] = req[:idQueryInstallments]
        end
        if req[:deferredPeriodIndex].present?
          payload["deferred_period_index"] = req[:deferredPeriodIndex]
        end
        if req[:gracePeriod].present?
          payload["grace_period"] = req[:gracePeriod].to_s.downcase == "true"
        end

        payload
      end

      resp = @tx.commit(req[:token], commit_details)

      @response_data = resp.respond_to?(:with_indifferent_access) ? resp.with_indifferent_access : resp
      @request_data = req
      render 'commit'
    rescue StandardError => e
      Rails.logger.error("Error en Transacción Completa Mall Diferida - Commit: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def capture
    req = params.permit(:token, :child_buy_order, :child_commerce_code, :authorization_code, :amount)

    begin
      resp = @tx.capture(
        req[:token],
        req[:child_commerce_code],
        req[:child_buy_order],
        req[:authorization_code],
        req[:amount].to_i
      )

      @request_data = req
      @response_data = resp
      render 'capture'
    rescue StandardError => e
      Rails.logger.error("Error en Transacción Completa Mall Diferida - Capture: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def status
    req = params.permit(:token)

    begin
      resp = @tx.status(req[:token])

      @response_data = resp.respond_to?(:with_indifferent_access) ? resp.with_indifferent_access : resp
      @request_data = req
      render 'status'
    rescue StandardError => e
      Rails.logger.error("Error en Transacción Completa Mall Diferida - Status: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refund
    req = params.permit(:token, :buy_order, :commerce_code, :amount)

    begin
      resp = @tx.refund(req[:token], req[:buy_order], req[:commerce_code], req[:amount].to_i)

      @request_data = req
      @response_data = resp
      render 'refund'
    rescue StandardError => e
      Rails.logger.error("Error en Transacción Completa Mall Diferida - Refund: #{e.message}")
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  private

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::TRANSACCION_COMPLETA_MALL_DEFERRED
    api_key = ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::TransaccionCompleta::MallTransaction.new(options)
  end

  def build_mall_details
    [
      {
        amount: rand(1001..2000),
        commerce_code: ::Transbank::Common::IntegrationCommerceCodes::TRANSACCION_COMPLETA_MALL_DEFERRED_CHILD1,
        buy_order: "O-#{rand(1..10000)}"
      },
      {
        amount: rand(1001..2000),
        commerce_code: ::Transbank::Common::IntegrationCommerceCodes::TRANSACCION_COMPLETA_MALL_DEFERRED_CHILD2,
        buy_order: "O-#{rand(1..10000)}"
      }
    ]
  end
end
