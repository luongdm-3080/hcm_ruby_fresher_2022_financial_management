class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = t ".success_message"
      redirect_to home_url
    else
      flash.now[:danger] = t ".failure_message"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(User::USER_SINGUP_ATTRS)
  end
end
