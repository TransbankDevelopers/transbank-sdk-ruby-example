class OneclickMallDeferredController < ApplicationController
  skip_before_action :verify_authenticity_token

  logger = Logger.new(STDOUT)
  ERROR_PAGE = "shared/error_page".freeze
  PRODUCT = "Oneclick Mall Diferido".freeze
  REJECTED_PAGE = "error/oneclick/rejected".freeze
  RECOVER_PAGE = "error/oneclick/recover".freeze
  before_action :set_transbank_transaction

  def start
    begin
      @username = "User-#{rand(1000)}"
      @email = "user.#{rand(1000)}@example.com"
      @response_url = oneclick_mall_deferred_finish_url
      create_ins = {
        username: @username,
        email: @email,
        response_url: @response_url
      }
      session[:username] = @username
      session[:email] = @email
      @resp = @inscription.start(@username, @email, @response_url)  
      @request_data = create_ins
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def finish
    begin
      @req = params.as_json
      @response_url = oneclick_mall_deferred_finish_url
      @token = @req["TBK_TOKEN"]

      if @req["TBK_ORDEN_COMPRA"].present?
        @request_data = @req.slice("TBK_ORDEN_COMPRA", "TBK_TOKEN", "TBK_ID_SESION")
        @navigation = {
          "inscription-failed" => "Inscripción Fallida",
          "data" => "Datos recibidos",
          "request" => "Petición",
          "response" => "Respuesta"
        }
        return render RECOVER_PAGE, locals: {
          breadcrumbs: [
            { label: "Inicio", path: root_path },
            { label: PRODUCT, path: oneclick_mall_deferred_start_path },
            { label: "Inscripción anulada", path: oneclick_mall_deferred_finish_path }
          ],
          product: PRODUCT,
          request_data: @request_data
        }
      end

      @resp = @inscription.finish(@token)  
      @respond_data = @resp.with_indifferent_access
      response_code = @respond_data[:response_code] || @respond_data[:responseCode] || 0

      if response_code.to_i != 0
        @navigation = {
          "inscription-failed" => "Inscripción Fallida",
          "data" => "Datos recibidos",
          "request" => "Petición",
          "response" => "Respuesta"
        }
        return render REJECTED_PAGE, locals: {
          breadcrumbs: [
            { label: "Inicio", path: root_path },
            { label: PRODUCT, path: oneclick_mall_deferred_start_path },
            { label: "Inscripción Fallida", path: oneclick_mall_deferred_finish_path }
          ],
          product: PRODUCT,
          response_data: @respond_data,
          token: @token
        }
      end

      session[:tbk_user] = @respond_data[:tbk_user] || @respond_data[:tbkUser]
      @username = session[:username]
      @tbk_user = session[:tbk_user]
      @child_commerce_code1 = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL_DEFERRED_CHILD1
      @child_commerce_code2 = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL_DEFERRED_CHILD2
      @request_data  = {
        username: @username,
        tbk_user: @tbk_user
      }
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def delete
    begin
      @req = params.as_json
      @username = @req['username']
      @tbk_user = @req['tbk_user']
      @resp = @inscription.delete(@tbk_user, @username)
      @respond_data = {}
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def authorize
    begin
      @req = params.as_json
      @username = @req['username']
      @tbk_user = @req['tbk_user']
      @buy_order = "buyOrder_#{rand(1000)}"
      @child_commerce_code1 = @req['child_commerce_code1']
      @child_commerce_code2 = @req['child_commerce_code2']
      @child_commerce_amount1 = @req['child_commerce_amount1']
      @child_commerce_amount2 = @req['child_commerce_amount2']
      @child_commerce_installments1 = @req['child_commerce_installments1']
      @child_commerce_installments2 = @req['child_commerce_installments2']
      @details =[
        {
          commerce_code: @child_commerce_code1,
          buy_order: "childBuyOrder1_#{rand(1000)}",
          amount: @child_commerce_amount1,
          installments_number: @child_commerce_installments1
        },
        {
          commerce_code: @child_commerce_code2,
          buy_order: "childBuyOrder2_#{rand(1000)}",
          amount: @child_commerce_amount2,
          installments_number: @child_commerce_installments2
        }
      ]
      @resp = @tx.authorize(@username, @tbk_user, @buy_order, @details)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def status
    begin
      @req = params.as_json
      @buy_order = params[:buy_order]
      @resp = @tx.status(@buy_order)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refund
    begin
      @req = params.as_json
      @buy_order = params[:buy_order] 
      @child_commerce_code = params[:child_commerce_code] 
      @child_buy_order = params[:child_buy_order] 
      @amount = params[:amount] 
      @resp = @tx.refund(@buy_order, @child_commerce_code, @child_buy_order, @amount)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end


  def capture
    begin
      @req = params.as_json
      @buy_order = params[:buy_order]
      @child_buy_order = params[:child_buy_order]
      @authorization_code = params[:authorization_code]
      @amount = params[:amount]
      @child_commerce_code = params[:child_commerce_code]

      @resp = @tx.capture(@child_commerce_code, @child_buy_order, @authorization_code, @amount)  
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL_DEFERRED
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::Oneclick::MallTransaction.new(options)
    @inscription = Transbank::Webpay::Oneclick::MallInscription.new(options)
  end

end
