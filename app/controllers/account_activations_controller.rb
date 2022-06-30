class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = t ".success_message"
    else
      flash[:danger] = t ".failure_message"
    end
    redirect_to root_url
  end
end
