require 'logger'

class PatpassComercioController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :commit, :voucher ]

  ERROR_PAGE = "shared/error_page".freeze
  logger = Logger.new(STDOUT)

  before_action :set_patpass_inscription

  def start
    begin
      base_url = request.base_url
      start_tx = {
        service_id: "Service-#{SecureRandom.random_number(1..10000)}",
        max_amount: 100,
        return_url: "#{base_url}/patpass-comercio/commit",
        final_url: "#{base_url}/patpass-comercio/voucher"
      }

      patpass_data = {
        name: "Isaac",
        last_name: "Newton",
        second_last_name: "Gonzales",
        rut: "11111111-1",
        phone: "123456734",
        cell_phone: "123456723",
        patpass_name: "Membresia de cable",
        person_email: "developer@continuum.cl",
        commerce_email: "developer@continuum.cl",
        address: "Satelite 101",
        city: "Santiago"
      }

      @resp = @inscription.start(
        start_tx[:return_url],
        patpass_data[:name],
        patpass_data[:last_name],
        patpass_data[:second_last_name],
        patpass_data[:rut],
        start_tx[:service_id],
        start_tx[:final_url],
        start_tx[:max_amount],
        patpass_data[:phone],
        patpass_data[:cell_phone],
        patpass_data[:patpass_name],
        patpass_data[:person_email],
        patpass_data[:commerce_email],
        patpass_data[:address],
        patpass_data[:city]
      )

      @request_data = start_tx.merge(patpass_data)
      @response_data = @resp.as_json
    rescue StandardError => e
      logger.error(e)
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def commit
    response = nil
    begin
      @j_token = params[:j_token] || params[:J_TOKEN] || params[:token] || session[:patpass_j_token]

      if request.post?
        if @j_token.present?
          session[:patpass_j_token] = @j_token
          response = redirect_to patpass_comercio_commit_path
        else
          response = render_patpass_error("No se recibió el token de inscripción (J_TOKEN).")
        end
      else
        if @j_token.present?
          session[:patpass_j_token] = @j_token

          @resp = @inscription.status(@j_token)
          status_payload = @resp.as_json || {}
          authorized = status_payload["authorized"] || status_payload["status"]
          voucher_url = status_payload["voucherUrl"] || status_payload["voucher_url"]

          @response_payload = {
            "authorized" => authorized,
            "voucherUrl" => voucher_url
          }
          response = render :commit
        else
          response = render_patpass_error("No se encontró el token de inscripción (J_TOKEN).")
        end
      end
    rescue StandardError => e
      logger.error(e)
      response = render ERROR_PAGE, locals: { error: e.message }
    end
    response
  end

  def voucher
    response = nil
    begin
      @j_token = params[:j_token] || params[:J_TOKEN] || params[:tokenComercio] || params[:token] || session[:patpass_j_token]

      if request.post?
        if @j_token.present?
          session[:patpass_j_token] = @j_token
          response = redirect_to patpass_comercio_voucher_path
        else
          response = render_patpass_error("No se recibió el token de inscripción (J_TOKEN).")
        end
      else
        if @j_token.present?
          response = render :voucher
        else
          response = render_patpass_error("No se encontró el token de inscripción (J_TOKEN).")
        end
      end
    rescue StandardError => e
      logger.error(e)
      response = render ERROR_PAGE, locals: { error: e.message }
    end
    response
  end

  private

  def render_patpass_error(message)
    render ERROR_PAGE, locals: { error: message }
  end

  def set_patpass_inscription
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::PATPASS_COMERCIO
    api_key = ::Transbank::Common::IntegrationApiKeys::PATPASS_COMERCIO

    options = Transbank::Patpass::Options.new(commerce_code, api_key, environment)
    @inscription = Transbank::Patpass::PatpassComercio::Inscription.new(options)
  end
end
