module TransaccionCompletaHelper
  def normalize_mall_details_from_session(session_key)
    (session[session_key] || []).map do |detail|
      detail.respond_to?(:with_indifferent_access) ? detail.with_indifferent_access : detail
    end
  end
end
