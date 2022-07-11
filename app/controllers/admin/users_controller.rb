class Admin::UsersController < Admin::AdminController
  def index
    @search = User.order_by_name.ransack(params[:search])
    @pagy, @users = pagy @search.result, items: Settings.default_page
    respond_to do |format|
      format.html
      format.js
    end
  end
end
