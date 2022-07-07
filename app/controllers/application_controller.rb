class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper
  include ApplicationHelper
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from CanCan::AccessDenied, with: :access_denied

  protected

  def configure_permitted_parameters
    added_attrs = [:name, :email, :password,
                   :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def access_denied
    flash[:danger] = t "authorzie_warning"
    redirect_to root_path
  end
end
