class UsersController < ApplicationController
  before_action :load_user, :logged_in_user, except: %i(new create)
  before_action :check_login, only: %i(new)
  before_action :user_correct, only: %i(show)

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".mail_activation_message"
      redirect_to root_url
    else
      flash.now[:danger] = t ".failure_message"
      render :new
    end
  end

  def show; end

  private

  def user_params
    params.require(:user).permit(User::USER_SINGUP_ATTRS)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_url
  end

  def user_correct
    user_corrects @user.id, current_user
  end
end
