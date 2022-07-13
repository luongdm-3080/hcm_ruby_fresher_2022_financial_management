class Admin::UsersController < Admin::AdminController
  before_action :load_user, only: %i(destroy restore really_destroy)

  def index
    @search = User.order_by_name.ransack(params[:search])
    @pagy, @users = pagy @search.result, items: Settings.default_page
    respond_to do |format|
      format.html
      format.js
    end
  end

  def restores
    @search = User.only_deleted.order_by_name.ransack(params[:search])
    @pagy, @users = pagy @search.result, items: Settings.default_page
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".destroy_success_message"
      redirect_to restores_admin_users_path
    else
      flash.now[:danger] = t ".destroy_failure_message"
      render :index
    end
  end

  def restore
    if @user.restore
      flash[:success] = t ".restore_success_message"
      redirect_to admin_root_path
    else
      flash.now[:danger] = t ".restore_failure_message"
      render :restores
    end
  end

  def really_destroy
    if @user.really_destroy!
      flash[:success] = t ".really_destroy_success"
    else
      flash[:danger] = t ".really_destroy_message"
    end
    redirect_to admin_root_path
  end

  def load_user
    @user = User.with_deleted.find_by id: params[:id]
    return if @user

    flash[:danger] = t "not_found_user"
    redirect_to admin_root_path
  end
end
