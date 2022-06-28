class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper
  include ApplicationHelper
  before_action :set_locale

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    redirect_to login_url
  end

  def check_login
    redirect_to home_url if logged_in?
  end

  def user_corrects user_id, url
    return if current_user? user_id

    flash[:danger] = t ".unauthorization"
    redirect_to url
  end
end
