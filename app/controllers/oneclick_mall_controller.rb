class OneclickMallController < ApplicationController
  skip_before_action :verify_authenticity_token

  logger = Logger.new(STDOUT)

  before_action :set_transbank_transaction

  def start
    begin
      @username = "User-#{rand(1000)}"
      @email = "user.#{rand(1000)}@example.com"
      @response_url = oneclick_mall_finish_url
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
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def finish
    begin
      @req = params.as_json
      @token = @req["TBK_TOKEN"]
      @resp = @inscription.finish(@token)  
      @response_url = oneclick_mall_finish_url
      @respond_data = @resp.with_indifferent_access
      session[:tbk_user] = @respond_data[:tbk_user]
      @username = session[:username]
      @tbk_user = @respond_data[:tbk_user]
      @child_commerce_code1 = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL_CHILD1
      @child_commerce_code2 = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL_CHILD2
      @request_data  = {
        username: @username,
        tbk_user: @tbk_user
      }
    rescue StandardError => e
      logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render "shared/error_page", locals: { error: e.message }
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
      render "shared/error_page", locals: { error: e.message }
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
      render "shared/error_page", locals: { error: e.message }
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
      render "shared/error_page", locals: { error: e.message }
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
      render "shared/error_page", locals: { error: e.message }
    end
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ::Transbank::Common::IntegrationCommerceCodes::ONECLICK_MALL
    api_key =  ::Transbank::Common::IntegrationApiKeys::WEBPAY

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::Oneclick::MallTransaction.new(options)
    @inscription = Transbank::Webpay::Oneclick::MallInscription.new(options)
  end

end
