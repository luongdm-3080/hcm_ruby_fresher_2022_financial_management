module SessionsHelper
  def current_user? user_id
    user_id && user_id.to_i == current_user.try(:id)
  end

  def is_admin?
    return unless user_signed_in?

    current_user.admin?
  end

  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
