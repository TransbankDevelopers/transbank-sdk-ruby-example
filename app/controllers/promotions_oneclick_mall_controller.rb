class PromotionsOneclickMallController < ApplicationController
  ERROR_PAGE = "shared/error_page".freeze
  before_action :set_transbank_transaction

  def start
    begin
      @username = "User-#{rand(1000)}"
      @email = "user.#{rand(1000)}@example.com"
      @response_url = promotions_oneclick_mall_finish_url
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
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def finish
    begin
      @req = params.as_json
      @token = @req["TBK_TOKEN"]
      @resp = @inscription.finish(@token)  
      @response_url = promotions_oneclick_mall_finish_url
      @respond_data = @resp.with_indifferent_access
      session[:tbk_user] = @respond_data[:tbk_user]
      @username = session[:username]
      @tbk_user = @respond_data[:tbk_user]
      @child_commerce_code1 = ENV.fetch("ONECLICK_MALL_PROMOTIONS_CHILD1_COMMERCE_CODE")
      @child_commerce_code2 = ENV.fetch("ONECLICK_MALL_PROMOTIONS_CHILD2_COMMERCE_CODE")
      @request_data  = {
        username: @username,
        tbk_user: @tbk_user
      }
    rescue StandardError => e
      Rails.logger.error(e)
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
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def authorize
    begin
      @req = params.as_json
      @username = required_text_param(:username)
      @tbk_user = required_text_param(:tbk_user)
      @buy_order = "buyOrder_#{rand(1000)}"
      @child_commerce_code1 = required_text_param(:child_commerce_code1)
      @child_commerce_code2 = required_text_param(:child_commerce_code2)
      @child_commerce_amount1 = required_decimal_param(:child_commerce_amount1)
      @child_commerce_amount2 = required_decimal_param(:child_commerce_amount2)
      @child_commerce_installments1 = required_integer_param(:child_commerce_installments1)
      @child_commerce_installments2 = required_integer_param(:child_commerce_installments2)
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
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def status
    begin
      @req = params.as_json
      @buy_order = required_text_param(:buy_order)
      @resp = @tx.status(@buy_order)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def refund
    begin
      @req = params.as_json
      @buy_order = required_text_param(:buy_order)
      @child_commerce_code = required_text_param(:child_commerce_code)
      @child_buy_order = required_text_param(:child_buy_order)
      @amount = required_decimal_param(:amount)
      @resp = @tx.refund(@buy_order, @child_commerce_code, @child_buy_order, @amount)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def info_bin
    begin
      @tbk_user = required_text_param(:tbk_user)
      @resp = @bin_info.query_bin(@tbk_user)
      @respond_data = @resp.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error(e)
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
      render ERROR_PAGE, locals: { error: e.message }
    end
  end

  def set_transbank_transaction
    environment = :integration
    commerce_code = ENV.fetch("ONECLICK_MALL_PROMOTIONS_COMMERCE_CODE")
    api_key = ENV.fetch("ONECLICK_MALL_PROMOTIONS_API_KEY")

    options = Transbank::Webpay::Options.new(commerce_code, api_key, environment)
    @tx = Transbank::Webpay::Oneclick::MallTransaction.new(options)
    @inscription = Transbank::Webpay::Oneclick::MallInscription.new(options)
    @bin_info = Transbank::Webpay::Oneclick::MallBinInfo.new(options)
  end

  def required_text_param(key)
    value = params[key]
    return value if value.present?

    raise ArgumentError, "El parámetro #{key} es obligatorio."
  end

  def required_decimal_param(key)
    BigDecimal(required_text_param(key).to_s)
  rescue ArgumentError
    raise ArgumentError, "El parámetro #{key} debe ser numérico."
  end

  def required_integer_param(key)
    Integer(required_text_param(key).to_s, 10)
  rescue ArgumentError
    raise ArgumentError, "El parámetro #{key} debe ser un entero."
  end

end
