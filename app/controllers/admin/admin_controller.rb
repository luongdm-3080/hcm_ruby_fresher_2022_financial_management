class Admin::AdminController < ApplicationController
  before_action :require_admin, :authenticate_user!
  private

  def require_admin
    return if is_admin?

    flash[:danger] = t ".unauthorization"
    redirect_to root_path
  end
end
