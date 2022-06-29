class Admin::AdminController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    return if logged_in? && is_admin?

    flash[:danger] = t ".unauthorization"
    redirect_to root_path
  end
end
